module Constants
  # http://www.armorpayments.com/api/classes/ArmorPayments.Api.Entity.Order.html
  module Order
    STATES = [
      { key: 0, value: 'STATUS_NEW', description: 'NEW ORDER' },
      { key: 1, value: 'STATUS_SENT', description: 'IN PROGRESS' },
      { key: 2, value: 'STATUS_PAID', description: 'PAYED' },
      { key: 3, value: 'STATUS_SHIPPED', description: 'SHIPPED' },
      { key: 4, value: 'STATUS_DELIVERED', description: 'DELIVERED' },
      { key: 5, value: 'STATUS_RELEASED', description: 'RELEASED' },
      { key: 6, value: 'STATUS_PENDING_INCOMPLETE', description: 'PENDING INCOMPLETE' },
      { key: 7, value: 'STATUS_PENDING_ERROR', description: 'PENDING ERROR' },
      { key: 8, value: 'STATUS_DISPUTE', description: 'DISPUTE' },
      { key: 9, value: 'STATUS_COMPLETE', description: 'COMPLETE' },
      { key: 10, value: 'STATUS_CANCELLED', description: 'CANCELED' },
      { key: 11, value: 'STATUS_ARBITRATION', description: 'ARBITRATION' },
      { key: 98, value: 'STATUS_CANCELLED_FINAL', description: 'CANCELLED FINAL' },
      { key: 99, value: 'STATUS_ARCHIVE', description: 'ARCHIVE' },
      { key: 255, value: 'STATUS_ERROR', description: 'ERROR' }
    ]

    TYPE = [
      { key: 1, value: 'TYPE_STANDARD_ESCROW' },
      { key: 2, value: 'TYPE_INSPECT_AND_PAY' },
      { key: 3, value: 'TYPE_SERVICES_ESCROW' },
      { key: 4, value: 'TYPE_SERVICES_MILESTONE' },
      { key: 5, value: 'TYPE_STANDARD_MILESTONE' }
    ]
  end
# [{name:'Bob',id:'12'}, {name:'Sam',id:'25'}]
# Constants::OrderEvent::TYPE.detect { |p| p[:key] == 12 }
  # http://www.armorpayments.com/api/classes/ArmorPayments.Api.Entity.OrderEvent.html
  module OrderEvent
    TYPE = [
      { key: 0, value: 'TYPE_ORDER_CREATE' },
      { key: 1, value: 'TYPE_SENT' },
      { key: 2, value: 'TYPE_PAID' },
      { key: 3, value: 'TYPE_GOODS_SHIPPED' },
      { key: 4, value: 'TYPE_GOODS_RECEIVED' },
      { key: 5, value: 'TYPE_DISPUTE' },
      { key: 6, value: 'TYPE_FUNDS_RELEASED' },
      { key: 7, value: 'TYPE_ARBITRATION' },
      { key: 8, value: 'TYPE_COMPLETE' },
      { key: 9, value: 'TYPE_UPLOAD_DOCUMENT' },
      { key: 10, value: 'TYPE_DISPUTE_OFFER' },
      { key: 11, value: 'TYPE_OFFER_ACCEPTED' },
      { key: 12, value: 'TYPE_OFFER_REJECTED' },
      { key: 13, value: 'TYPE_OFFER_COUNTERED' },
      { key: 14, value: 'TYPE_NOTE_ADDED' },
      { key: 15, value: 'TYPE_SHIPMENT_ADDED' },
      { key: 16, value: 'TYPE_CANCELLED' },
      { key: 17, value: 'TYPE_INSURED' },
      { key: 18, value: 'TYPE_MILESTONE_REACHED' },
      { key: 19, value: 'TYPE_MILESTONE_RELEASED' }
    ]
  end
end
