require_relative "../../test_helper"

module SmartAnswer::Calculators
  class CheckBenefitsSupportCalculatorTest < ActiveSupport::TestCase
    context CheckBenefitsSupportCalculator do
      context "#eligible_for_employment_and_support_allowance?" do
        should "return true if eligible for Employment and Support Allowance" do
          calculator = CheckBenefitsSupportCalculator.new
          calculator.over_state_pension_age = "no"
          calculator.disability_or_health_condition = "yes"
          calculator.disability_affecting_work = "yes_unable_to_work"

          assert calculator.eligible_for_employment_and_support_allowance?

          calculator.disability_affecting_work = "yes_limits_work"
          assert calculator.eligible_for_employment_and_support_allowance?
        end

        should "return false if not eligible for Employment and Support Allowance" do
          calculator = CheckBenefitsSupportCalculator.new
          calculator.over_state_pension_age = "no"
          calculator.disability_or_health_condition = "no"
          assert_not calculator.eligible_for_employment_and_support_allowance?
        end
      end

      context "#eligible_for_jobseekers_allowance?" do
        should "return true if eligible for Jobseeker's Allowance" do
          calculator = CheckBenefitsSupportCalculator.new
          calculator.where_do_you_live = "scotland"
          calculator.over_state_pension_age = "no"
          calculator.are_you_working = "no"
          calculator.disability_affecting_work = "yes_limits_work"
          assert calculator.eligible_for_jobseekers_allowance?

          calculator.where_do_you_live = "england"
          assert calculator.eligible_for_jobseekers_allowance?

          calculator.disability_affecting_work = nil
          assert calculator.eligible_for_jobseekers_allowance?
        end

        should "return false if not eligible for Jobseeker's Allowance" do
          calculator = CheckBenefitsSupportCalculator.new
          calculator.where_do_you_live = "northern-ireland"
          calculator.over_state_pension_age = "yes"
          calculator.are_you_working = "yes_over_16_hours_per_week"
          calculator.disability_affecting_work = "yes_unable_to_work"
          assert_not calculator.eligible_for_jobseekers_allowance?
        end
      end

      context "#eligible_for_pension_credit?" do
        should "return true if eligible for Pension Credit" do
          calculator = CheckBenefitsSupportCalculator.new
          calculator.over_state_pension_age = "no"
          assert calculator.eligible_for_pension_credit?
        end

        should "return false if not eligible for Pension Credit" do
          calculator = CheckBenefitsSupportCalculator.new
          calculator.over_state_pension_age = "yes"
          assert_not calculator.eligible_for_pension_credit?
        end
      end
    end
  end
end
