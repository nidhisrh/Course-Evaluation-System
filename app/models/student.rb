class Student < ApplicationRecord
    
    def self.to_csv
        attributes = %w{uin name section attempts score}
        CSV.generate(headers: true) do |csv|
          csv << attributes
          all.each do |student|
            csv << student.attributes.values_at(*attributes)
          end
        end
    end
    # def self.to_csv(student_ids, options = {})
    #     CSV.generate(options) do |csv|
    #       csv << student_ids
    #       all.each do |student|
    #         csv << student.attributes.values_at(*student_ids)
    #       end
    #     end
    # end
end
