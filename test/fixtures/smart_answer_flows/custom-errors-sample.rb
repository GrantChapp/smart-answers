module SmartAnswer
  class CustomErrorsSampleFlow < Flow
    def define
      name "custom-errors-sample"
      status :draft

      start_page

      value_question :how_many_things_do_you_own? do
        next_node do |response|
          raise SmartAnswer::InvalidResponse, :error_custom unless response.to_i.positive?

          outcome :done
        end
      end

      outcome :done
    end
  end
end
