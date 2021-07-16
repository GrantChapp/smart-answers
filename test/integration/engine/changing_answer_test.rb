require_relative "engine_test_helper"

class ChangingAnswerTest < EngineIntegrationTest
  with_and_without_javascript do
    should "be able to change country and date answers" do
      stub_content_store_has_item("/country-and-date-sample")
      stub_worldwide_api_has_locations(%w[argentina belarus])

      visit "/country-and-date-sample/y"

      select "Belarus", from: "response"
      click_on "Continue"

      within("#current-question") { assert_page_has_content "What date did you move there?" }
      fill_in "response[day]", with: "5"
      fill_in "response[month]", with: "5"
      fill_in "response[year]", with: "1975"
      click_on "Continue"

      within("#current-question") { assert_page_has_content "Which country were you born in?" }

      within(".govuk-summary-list__row:nth-child(1)") { click_on "Change" }

      within "#current-question" do
        assert_page_has_content "Which country do you live in?"
        assert page.has_selector? :select, "response", selected: "Belarus"
      end

      select "Argentina", from: "response"
      click_on "Continue"

      assert_current_url "/country-and-date-sample/y/argentina"

      fill_in "response[day]", with: "10"
      fill_in "response[month]", with: "6"
      fill_in "response[year]", with: "1985"
      click_on "Continue"

      within(".govuk-summary-list__row:nth-child(2)") { click_on "Change" }

      within "#current-question" do
        assert page.has_field? "Day", with: "10"
        assert page.has_field? "Month", with: "6"
        assert page.has_field? "Year", with: "1985"
      end

      fill_in "response[day]", with: "15"
      fill_in "response[month]", with: "4"
      fill_in "response[year]", with: "2000"
      click_on "Continue"

      assert_current_url "/country-and-date-sample/y/argentina/2000-04-15"
    end

    should "be able to change money and salary answers" do
      stub_content_store_has_item("/annual-bonus")

      visit "/annual-bonus/y"

      fill_in "response[amount]", with: "5000"
      select "month", from: "response[period]"
      click_on "Continue"

      within("#current-question") { assert_page_has_content "What size bonus do you want?" }
      fill_in "response", with: "1000000"
      click_on "Continue"

      within("#result-info") { assert_page_has_content "OK, here you go." }
      within(".govuk-summary-list__row:nth-child(1)") { click_on "Change" }

      within "#current-question" do
        assert page.has_field? "response[amount]", with: "5000.0"
        assert page.has_select? "response[period]", selected: "per month"
      end

      fill_in "response[amount]", with: "2000"
      select "week", from: "response[period]"
      click_on "Continue"

      assert_current_url "/annual-bonus/y/2000.0-week"

      fill_in "response", with: "2000000"
      click_on "Continue"

      within(".govuk-summary-list__row:nth-child(2)") { click_on "Change" }

      within("#current-question") { assert page.has_field? "response", with: "2000000.0" }

      fill_in "response", with: "3000000"
      click_on "Continue"

      assert_current_url "/annual-bonus/y/2000.0-week/3000000.0"
    end

    should "be able to change value and radio answers" do
      stub_content_store_has_item("/bridge-of-death")

      visit "/bridge-of-death/y"

      fill_in "response", with: "Lancelot"
      click_on "Continue"

      within("#current-question") { assert_page_has_content "What...is your quest?" }
      choose("To seek the Holy Grail", visible: false)
      click_on "Continue"

      within("#current-question") { assert_page_has_content "What...is your favorite colour?" }
      choose("Blue", visible: false)
      click_on "Continue"

      within("#result-info") { assert_page_has_content "Right, off you go." }
      within(".govuk-summary-list__row:nth-child(1)") { click_on "Change" }

      within("#current-question") { assert page.has_field? "response", with: "Lancelot" }

      fill_in "response", with: "Bors"
      click_on "Continue"

      assert_current_url "/bridge-of-death/y/Bors"

      within("#current-question") { assert_page_has_content "What...is your quest?" }
      choose("To seek the Holy Grail", visible: false)
      click_on "Continue"

      within("#current-question") { assert_page_has_content "What...is your favorite colour?" }
      choose("Blue", visible: false)
      click_on "Continue"

      within("#result-info") { assert_page_has_content "Right, off you go." }
      within(".govuk-summary-list__row:nth-child(2)") { click_on "Change" }

      within "#current-question" do
        assert page.has_checked_field?("To seek the Holy Grail", visible: false)
        assert page.has_unchecked_field?("To rescue the princess", visible: false)
        assert page.has_unchecked_field?("I dunno", visible: false)
      end

      choose("To rescue the princess", visible: false)
      click_on "Continue"

      assert_current_url "/bridge-of-death/y/Bors/to_rescue_the_princess"

      choose("Blue", visible: false)
      click_on "Continue"

      within("#result-info") { assert_page_has_content "Right, off you go." }
      within(".govuk-summary-list__row:nth-child(3)") { click_on "Change" }

      within "#current-question" do
        assert page.has_checked_field?("Blue", visible: false)
        assert page.has_unchecked_field?("Blue... NO! YELLOOOOOOOOOOOOOOOOWWW!!!!", visible: false)
        assert page.has_unchecked_field?("Red", visible: false)
      end

      choose("Red", visible: false)
      click_on "Continue"

      assert_current_url "/bridge-of-death/y/Bors/to_rescue_the_princess/red"
    end

    should "be able to change checkbox answers" do
      stub_content_store_has_item("/checkbox-sample")

      visit "/checkbox-sample/y"

      check("Peppers", visible: false)
      check("Pepperoni", visible: false)
      click_on "Continue"

      assert_current_url "/checkbox-sample/y/pepperoni,peppers"

      within(".govuk-summary-list__row:nth-child(1)") { click_on "Change" }

      within "#current-question" do
        assert page.has_unchecked_field?("Ham", visible: false)
        assert page.has_checked_field?("Peppers", visible: false)
        assert page.has_unchecked_field?("Ice Cream!!!", visible: false)
        assert page.has_checked_field?("Pepperoni", visible: false)
      end

      check("Ham", visible: false)
      click_on "Continue"

      assert_current_url "/checkbox-sample/y/ham,pepperoni,peppers"
    end

    should "be able to change postcode answer" do
      stub_content_store_has_item("/postcode-sample")

      visit "/postcode-sample/y"

      fill_in "response", with: "B1 1PW"
      click_on "Continue"

      assert_current_url "/postcode-sample/y/B1%201PW"

      within(".govuk-summary-list__row:nth-child(1)") { click_on "Change" }

      within "#current-question" do
        assert page.has_field? "response", with: "B1 1PW"
      end
    end
  end
end
