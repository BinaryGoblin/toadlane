module Services
  module Importers
    class Product
      def self.import(folder, current_user)
        download_url = folder.import.url
        extname = File.extname(folder.import_file_name)
        file_name = folder.id.to_s + Time.now.to_i.to_s + extname

        open(file_name, 'wb') do |file|
          file << open(download_url).read
        end

        product_data = Roo::Spreadsheet.open(file_name)
        File.delete(file_name) if File.exist?(file_name.to_s)
        product_data.default_sheet = product_data.sheets.first

        header = product_data.row(4)
        raise "Invalid headers! Headers must be matched with '#{::Product::TEMPLATE_HEADER.join(', ')}'" unless (header == ::Product::TEMPLATE_HEADER)


        6.upto(product_data.last_row) do |line|
          product_name = product_data.cell(line, 'A').to_s.strip
          model = product_data.cell(line, 'B').to_s.strip
          brand = product_data.cell(line, 'C').to_s.strip
          sku = product_data.cell(line, 'D').to_s.strip
          amount_in_stock = product_data.cell(line, 'E').to_s.strip
          unit_price = product_data.cell(line, 'F').to_s.strip
          valid_from = product_data.cell(line, 'G').to_s.strip
          valid_until = product_data.cell(line, 'H').to_s.strip
          minimum_order_quantity = product_data.cell(line, 'I').to_s.strip
          product_description = product_data.cell(line, 'J').to_s.strip
          condition = product_data.cell(line, 'K').to_s.strip
          product_tags = product_data.cell(line, 'L').to_s.strip
          sell_product_using = product_data.cell(line, 'M').to_s.strip
          start_date = Date.strptime(valid_from, '%Y-%m-%d') rescue nil
          end_date = Date.strptime(valid_until, '%Y-%m-%d') rescue nil

          product_params = { name: product_name, model: model, brand: brand, condition: condition, sku: sku, unit_price: unit_price, amount: amount_in_stock, start_date: start_date,
            end_date: end_date, tag_list: product_tags, minimum_order_quantity: minimum_order_quantity,
            folder_id: folder.id, status_characteristic: 'sell', default_payment: sell_product_using,
            status: true }

          Crud::Product.new(product_params, current_user).save!
        end
      end
    end
  end
end