const std = @import("std");
const testing = std.testing;

const OrderSide = enum {
    None,
    Buy,
    Sell,
};

const BookError = error {
    OrderNotExists,
    OrderAlreadyCancelled,
};

const Order = struct {
    id: u32 = 0,
    side: OrderSide,
    quantity: u32,
    price: f64,
    entryTime: i64 = 0,
    parent: ?*LimitNode = null,
};

const Limit = struct {
    price: f64,
    quantity: u32,
    orders: std.DoublyLinkedList(Order),
};

const OrderNode = std.DoublyLinkedList(Order).Node;
const LimitNode = std.DoublyLinkedList(Limit).Node;

pub const Book = struct {
    orderCount: u32 = 0,
    buyList: std.DoublyLinkedList(Limit),
    sellList: std.DoublyLinkedList(Limit),
    orders: std.ArrayList(?*OrderNode),
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator) Book {
        return Book {
            .allocator = allocator,
            .buyList = std.DoublyLinkedList(Limit){},
            .sellList = std.DoublyLinkedList(Limit){},
            .orders = std.ArrayList(?*OrderNode).init(allocator),
        };
    }

    pub fn deinit(self: Book) void {
        for (self.orders.items) |orderNode| {
            if (orderNode) |node| {
                self.allocator.destroy(node);
            }
        }
        self.cleanList(std.DoublyLinkedList(Limit), self.buyList);
        self.cleanList(std.DoublyLinkedList(Limit), self.sellList);
        self.orders.deinit();
    }

    fn cleanList(self: Book, T: type, list: T) void {
        var curr = list.first;
        while (true) {
            if (curr) |pos| {
                var next = pos.next;
                _ = &next;
                if (@TypeOf(T) == std.DoublyLinkedList(Limit)) {
                    self.cleanList(self, std.DoublyLinkedList(Order), pos.data.orders);
                }
                self.allocator.destroy(pos);
                curr = next;
            } else {
                break;
            }
            if (curr == list.last) {
                if (@TypeOf(T) == std.DoublyLinkedList(Limit)) {
                    self.cleanList(self, std.DoublyLinkedList(Order), curr.?.data.orders);
                }
                if (curr) |node| {
                    self.allocator.destroy(node);
                }
                break;
            }
        }
    }

    pub fn cancelOrder(self: *Book, orderId: u32) !void {
        if (orderId >= self.orderCount) {
            return BookError.OrderNotExists;
        }
        if (self.orders.items[orderId]) |orderNode| {
            const side = orderNode.data.side;
            const limitNode = orderNode.data.parent.?;
            limitNode.data.orders.remove(orderNode);
            self.allocator.destroy(orderNode);
            self.orders.items[orderId] = null;
            if (limitNode.data.orders.first == null and limitNode.data.orders.last == null) {
                var list = if (side == OrderSide.Buy) self.buyList else self.sellList;
                list.remove(limitNode);
                self.allocator.destroy(limitNode);
            }
            return;
        }
        return BookError.OrderAlreadyCancelled;
    }

    pub fn addOrder(self: *Book, side: OrderSide, quantity: u32, price: f64) !u32 {
        const orderNode = try self.allocator.create(OrderNode);
        orderNode.* = OrderNode{.data = Order{
            .side = side,
            .quantity = quantity,
            .price = price,
        }};
        orderNode.data.entryTime = std.time.microTimestamp();
        orderNode.data.id = self.orderCount;
        self.orderCount += 1;
        try self.orders.append(orderNode);
        try self._addOrder(orderNode);
        return orderNode.data.id;
    }

    fn _addOrder(self: *Book, orderNode: *OrderNode) !void {
        const order = orderNode.data;
        const list = if (order.side == OrderSide.Buy) &self.buyList else &self.sellList;
        var curr = list.first;
        if (curr == null) {
            const limitNode = try self.allocator.create(LimitNode);
            limitNode.* = LimitNode{.data=Limit{
                .price = order.price,
                .quantity = order.quantity,
                .orders = std.DoublyLinkedList(Order){},
            }};
            list.*.append(limitNode);
            limitNode.data.orders.append(orderNode);
            orderNode.data.parent = limitNode;
        }
        else while (true) {
            var limit = curr.?.data;
            if (limit.price == order.price) {
                limit.quantity += order.quantity;
                limit.orders.append(orderNode);
                break;
            }
            const cond = if (order.side == OrderSide.Buy) order.price > limit.price
                else order.price < limit.price; 
            if (cond) {
                const limitNode = try self.allocator.create(LimitNode);
                limitNode.* = LimitNode{.data=Limit{
                    .price = order.price,
                    .quantity = order.quantity,
                    .orders = std.DoublyLinkedList(Order){},
                }};
                list.insertBefore(curr.?, limitNode);
                limitNode.data.orders.append(orderNode);
                orderNode.data.parent = limitNode;
                break;
            }
            if (curr == list.last) {
                const limitNode = try self.allocator.create(LimitNode);
                limitNode.* = LimitNode{.data=Limit{
                    .price = order.price,
                    .quantity = order.quantity,
                    .orders = std.DoublyLinkedList(Order){},
                }};
                list.append(limitNode);
                limitNode.data.orders.append(orderNode);
                orderNode.data.parent = limitNode;
                break;
            }
            curr = curr.?.next;
        }
    }

    pub fn bidPrice(self: Book) f64 {
        if (self.buyList.first) |top| {
            return top.data.price;
        }
        return std.math.nan(f64);
    }

    pub fn bidQuantity(self: Book) u32 {
        if (self.buyList.first) |top| {
            return top.data.quantity;
        }
        return 0;
    }

    pub fn askPrice(self: Book) f64 {
        if (self.sellList.first) |top| {
            return top.data.price;
        }
        return std.math.nan(f64);
    }

    pub fn askQuantity(self: Book) u32 {
        if (self.sellList.first) |top| {
            return top.data.quantity;
        }
        return 0;
    }

};

test "LOB Basic" {
    const allocator = std.testing.allocator;
    var book = Book.init(allocator);
    const order1 = try book.addOrder(OrderSide.Buy, 100, 12.50);
    const order2 = try book.addOrder(OrderSide.Buy, 150, 12.40);
    // _ = try book.addOrder(OrderSide.Buy, 200, 12.30);
    const order3 = try book.addOrder(OrderSide.Sell, 150, 12.70);
    const order4 = try book.addOrder(OrderSide.Sell, 50, 12.60);
    try std.testing.expect(order1 == 0);
    try std.testing.expect(order2 == 1);
    try std.testing.expect(order3 == 2);
    try std.testing.expect(order4 == 3);
    try std.testing.expect(book.bidPrice() == 12.50);
    try std.testing.expect(book.askPrice() == 12.60);
    try std.testing.expect(book.bidQuantity() == 100);
    try std.testing.expect(book.askQuantity() == 50);
    // try book.cancelOrder(order2);
    defer book.deinit();
}
