# frozen_string_literal: true

require_relative 'selenium_wrapper/selenium_wrapper_exceptions'
module OnlyofficeDocumentserverTestingFramework
  # Module for handle selenium with frames and some other methods
  module SeleniumWrapper
    def error_ignored?(error_message)
      ignored_errors = File.readlines("#{Dir.pwd}/lib/onlyoffice_documentserver_testing_framework/selenium_wrapper/ingored_errors.list")
                           .map(&:strip)
      ignored_errors.any? { |word| error_message.include?(word) }
    end

    def selenium_functions(name, *arguments)
      select_frame do
        @instance.selenium.send name, *arguments
      end
    end

    def select_frame
      count_of_frame = @count_of_frame ? frame_count_addition : @instance.management.xpath_iframe_count
      xpath_of_frame = @xpath_of_frame || @instance.management.xpath_iframe
      @instance.selenium.select_frame xpath_of_frame, count_of_frame
      value = yield
      fail_if_console_error
      @instance.selenium.select_top_frame
      value
    end

    # @return [Integer] frame count with addition
    def frame_count_addition
      @count_of_frame + @instance.management.xpath_iframe_count - 1
    end

    def console_errors
      severe_error = []
      @instance.webdriver.browser_logs.each do |log|
        severe_error << log.message if log.level.include?('SEVERE') && !error_ignored?(log.message)
      end
      severe_error
    end

    alias get_console_errors console_errors
    extend Gem::Deprecate
    deprecate :get_console_errors, :console_errors, 2025, 1

    def fail_if_console_error
      errors = get_console_errors
      return if errors.empty?

      @instance.webdriver.webdriver_error(Selenium::WebDriver::Error::JavascriptError,
                                          "There are some errors in the Web Console: #{errors}")
    end

    # This method return true if xpath visible on the web page
    # @param[String] xpath
    # @return [Boolean]
    def visible?(xpath)
      selenium_functions :element_visible?, xpath
    end

    alias element_visible? visible?
    alias element_present_and_visible? visible?

    # This method click over button by xpath
    # @param[String] xpath
    def click_on_button(xpath)
      selenium_functions :click_on_locator, xpath
    end

    # This method return true if button pressed
    # @param[String] xpath
    # @return [Boolean]
    def button_pressed?(xpath)
      selenium_functions(:get_attribute, xpath, 'class').include?('active')
    end

    alias button_active? button_pressed?

    # This method return true if button disabled
    # @param[String] xpath
    # @return [Boolean]
    def button_disabled?(xpath)
      selenium_functions(:get_attribute, xpath, 'class').include?('disabled')
    end

    def button_menu_active?(xpath)
      selenium_functions(:get_attribute, xpath, 'class').include?('menu-active')
    end

    # This method return true if button menu open
    # @param[String] xpath
    # @return [Boolean]
    def button_menu_open?(xpath)
      element_visible = visible?(xpath)
      element_visible = selenium_functions(:get_attribute, xpath, 'class').include?('open') if element_visible
      element_visible
    end

    def click_on_of_several_by_display_button(xpath)
      selenium_functions :click_on_one_of_several_by_display, xpath
    end

    def click_on_displayed_button(xpath)
      selenium_functions :wait_element, xpath
      selenium_functions :click_on_displayed, xpath
    end

    def line_enabled?(xpath)
      selenium_functions :element_visible?, xpath
    end

    def line_checked?(xpath)
      selenium_functions(:get_attribute, xpath, 'class').include?('checked')
    end

    def menu_disabled?(xpath)
      selenium_functions(:get_attribute, xpath, 'class').include?('disabled')
    end

    def move_to_element(xpath)
      selenium_functions :move_to_element_by_locator, xpath
    end

    def remove_element(xpath)
      selenium_functions :remove_element, xpath
    end

    def get_attribute(xpath, attribute)
      selenium_functions :get_attribute, xpath, attribute
    end
  end
end
