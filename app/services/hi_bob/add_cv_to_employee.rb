module HiBob
  class AddCvToEmployee
    def initialize
      @document_creator = Apis::HiBob::People::AddSharedDocument.new
    end

    def call(employee_id, document_name, document_url)
      @document_creator.call(person_id: employee_id, document_name:, document_url:)
    rescue Apis::HiBob::BadRequestError => e
      raise HiBob::Error.new('Failed to add CV to employee: invalid data', e)
    rescue StandardError => e
      raise HiBob::Error.new("Failed to add CV to employee #{employee_id}: #{e.message}", e)
    end
  end
end
