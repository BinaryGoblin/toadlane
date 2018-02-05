module InspectionServiceHelper
  protected

  def inspected_items_count(percentage, quantity)
    items = ((quantity * percentage.to_f)/100).round
    items
  end
end
