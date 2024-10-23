//! A basic Graph type to use with Zig's primitive types

const std = @import("std");

/// A graph can be of type directed or undirected
pub const GraphType = enum {
    Directed,
    Undirected,
};

pub const GraphError = error{
    NodeAlreadyExists,
    NodeNotExists,
    EdgeAlreadyExists,
    EdgeNotExists,
    PathNotExists,
};

pub fn Graph(comptime T: type, W: type) type {
    return struct {
        const Node = struct {
            value: T,
            conns: std.ArrayList(T),
            weights: std.ArrayList(?W),
        };

        const Edge = struct {
            a: T,
            b: T,
        };

        const Self = @This();
        root: std.ArrayList(Node),
        allocator: std.mem.Allocator,
        gType: GraphType,

        pub fn init(comptime allocator: std.mem.Allocator, comptime gType: GraphType) !Self {
            var root = std.ArrayList(Node).init(allocator);
            _ = &root;
            return Self{
                .root = root,
                .gType = gType,
                .allocator = allocator,
            };
        }

        pub fn deinit(self: *const Self) void {
            for (self.root.items) |vertex| {
                vertex.conns.deinit();
                vertex.weights.deinit();
            }
            self.root.deinit();
        }

        pub fn hasNode(self: *const Self, vertex: T) bool {
            var has = false;
            for (self.root.items) |item| {
                if (item.value == vertex) {
                    has = true;
                    break;
                }
            }
            return has;
        }

        pub fn hasEdge(self: *Self, vertex_a: T, vertex_b: T) bool {
            const conns = self.getNeighbours(vertex_a);
            if (conns) |elems| {
                for (elems.items) |vertex| {
                    if (vertex == vertex_b) {
                        return true;
                    }
                }
            }
            return false;
        }

        pub fn addNode(self: *Self, vertex: T) !void {
            if (self.hasNode(vertex)) {
                return GraphError.NodeAlreadyExists;
            }
            var node = Node{
                .value = vertex,
                .conns = std.ArrayList(T).init(self.allocator),
                .weights = std.ArrayList(?W).init(self.allocator),
            };
            _ = &node;
            try self.root.append(node);
        }

        pub fn addNodesFrom(self: *Self, vertices: []T) !void {
            for (vertices) |vertex| {
                try self.addNode(vertex);
            }
        }

        fn getNeighbours(self: *Self, vertex: T) ?*std.ArrayList(T) {
            for (0..self.root.items.len) |i| {
                if (self.root.items[i].value == vertex) {
                    return &self.root.items[i].conns;
                }
            }
            return null;
        }

        fn getNode(self: *Self, vertex: T) ?*Node {
            for (0..self.root.items.len) |i| {
                if (self.root.items[i].value == vertex) {
                    return &self.root.items[i];
                }
            }
            return null;
        }

        fn _addEdge(self: *Self, vertex_a: T, vertex_b: T, weight: ?W) !void {
            if (!self.hasNode(vertex_b)) {
                try self.addNode(vertex_b);
            }
            if (!self.hasNode(vertex_a)) {
                try self.addNode(vertex_a);
            }
            var node = self.getNode(vertex_a);
            _ = &node;
            if (node) |n| {
                for (n.conns.items) |vertex| {
                    if (vertex == vertex_b) {
                        return GraphError.EdgeAlreadyExists;
                    }
                }
                try n.conns.append(vertex_b);
                try n.weights.append(weight);
            }
        }

        pub fn addWeightedEdge(self: *Self, vertex_a: T, vertex_b: T, weight: ?W) !void {
            try self._addEdge(vertex_a, vertex_b, weight);
            if (self.gType == GraphType.Undirected) {
                try self._addEdge(vertex_b, vertex_a, weight);
            }
        }

        pub fn addEdge(self: *Self, vertex_a: T, vertex_b: T) !void {
            try self.addWeightedEdge(vertex_a, vertex_b, undefined);
        }

        pub fn numberOfNodes(self: *const Self) u64 {
            return self.root.items.len;
        }

        pub fn numberOfEdges(self: *const Self) u64 {
            var count: u64 = 0;
            for (self.root.items) |node| {
                count += node.conns.items.len;
            }
            return count;
        }

        pub fn getWeight(self: *Self, vertex_a: T, vertex_b: T) !?W {
            const node = self.getNode(vertex_a);
            if (node) |n| {
                for (0..n.conns.items.len) |i| {
                    if (n.conns.items[i] == vertex_b) {
                        return n.weights.items[i];
                    }
                }
            }
            return GraphError.EdgeNotExists;
        }

        pub fn getSuccesors(self: *Self, allocator: std.mem.Allocator, vertex: T) ![]T {
            const node = self.getNode(vertex);
            if (node) |n| {
                const res = try allocator.alloc(T, n.conns.items.len);
                std.mem.copyForwards(T, res, n.conns.items);
                return res;
            }
            return GraphError.NodeNotExists;
        }

        /// Return a list of vertex that are predecessor of the required one.
        /// If the required vertex doesn't exist, an error is returned.
        /// If the required vertex doesn't have any predecessor, a empty list
        /// is returned.
        pub fn getPredecessors(self: *Self, allocator: std.mem.Allocator, vertex: T) ![]T {
            var pred = std.ArrayList(T).init(self.allocator);
            _ = &pred;
            defer pred.deinit();
            for (self.root.items) |item| {
                for (item.conns.items) |v| {
                    if (vertex == v) {
                        try pred.append(item.value);
                    }
                }
            }
            const res = try allocator.alloc(T, pred.items.len);
            std.mem.copyForwards(T, res, pred.items);
            return res;
        }
    };
}

test "GraphAddingNodes" {
    var g = try Graph(u32, f32).init(std.testing.allocator, GraphType.Directed);
    defer g.deinit();
    try g.addNode(0);
    try std.testing.expect(g.hasNode(0));
    var x = [_]u32{ 1, 2, 3, 4, 5 };
    try g.addNodesFrom(&x);
    for (x) |value| {
        try std.testing.expect(g.hasNode(value));
    }
    try std.testing.expect(!g.hasNode(10));
}

test "GraphAddingEdges" {
    var g = try Graph(u16, f16).init(std.testing.allocator, GraphType.Undirected);
    defer g.deinit();
    try g.addWeightedEdge(5, 3, 1.0);
    try std.testing.expect(g.hasNode(5));
    try std.testing.expect(g.hasNode(3));
    try std.testing.expect(!g.hasNode(8));
    try std.testing.expect(g.hasEdge(5, 3));
    try std.testing.expect(g.hasEdge(3, 5));
    try std.testing.expect(!g.hasEdge(8, 5));
    const weight = try g.getWeight(5, 3);
    if (weight) |w| {
        try std.testing.expect(w == 1.0);
        try std.testing.expect(w != 5.0);
    }
}

test "GraphBasicMetrics" {
    var g = try Graph(u8, f16).init(std.testing.allocator, GraphType.Undirected);
    defer g.deinit();
    try std.testing.expect(g.numberOfNodes() == 0);
    try g.addEdge(5, 3);
    try std.testing.expect(g.numberOfNodes() == 2);
    try std.testing.expect(g.numberOfEdges() == 2);
}

test "GraphPredSuc" {
    var g = try Graph(u8, f16).init(std.testing.allocator, GraphType.Directed);
    defer g.deinit();
    try g.addEdge(1, 2);
    try g.addEdge(2, 3);
    try g.addEdge(1, 3);
    try g.addEdge(2, 4);
    try g.addEdge(4, 1);
    const pred = try g.getPredecessors(std.testing.allocator, 4);
    defer std.testing.allocator.free(pred);
    try std.testing.expect(std.mem.eql(u8, &[_]u8{2}, pred));
    const succ = try g.getSuccesors(std.testing.allocator, 1);
    defer std.testing.allocator.free(succ);
    try std.testing.expect(std.mem.eql(u8, &[_]u8{2, 3}, succ));
}
