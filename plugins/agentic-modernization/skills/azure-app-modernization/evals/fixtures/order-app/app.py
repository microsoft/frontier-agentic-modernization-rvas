"""Small static evidence fixture; assessment does not execute this module."""

from decimal import Decimal


def submit_order(actor, lines, db, inventory, notifications):
    if "sales" not in actor.roles:
        raise PermissionError("Sales role required")
    if not lines:
        raise ValueError("Order needs at least one line")
    total = sum(Decimal(item["price"]) * item["quantity"] for item in lines)
    order_id = db.insert_order(actor.id, total, "pending")
    try:
        inventory.reserve(order_id, lines)
    except TimeoutError:
        db.set_status(order_id, "reservation_unknown")
        raise
    db.set_status(order_id, "accepted")
    notifications.publish("order.accepted", {"order_id": order_id})
    return {"id": order_id, "total": str(total)}
