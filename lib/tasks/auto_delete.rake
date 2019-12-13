## rake auto_delete:auto_job

namespace :auto_delete do
  desc "TODO"
  task auto_job: :environment do
    
    require 'selenium-webdriver'
    if Rails.env.development?
      # Selenium::WebDriver::Chrome.driver_path = `which chromedriver-helper`.chomp
    else
      Selenium::WebDriver::Chrome.driver_path = `which chromedriver-helper`.chomp
    end
    
    ## 헤드리스 개념 : https://beomi.github.io/2017/09/28/HowToMakeWebCrawler-Headless-Chrome/
    options = Selenium::WebDriver::Chrome::Options.new # 크롬 헤드리스 모드 위해 옵션 설정
    options.add_argument('--disable-gpu') # 크롬 헤드리스 모드 사용 위해 disable-gpu setting
    options.add_argument('--headless') # 크롬 헤드리스 모드 사용 위해 headless setting
    begin
      @browser = Selenium::WebDriver.for :chrome, options: options # 실레니움 + 크롬 + 헤드리스 옵션으로 브라우저 실행
    rescue 
      puts "에러 발생! 관리자에게 메일이 발송됩니다.." 
      @errorMessage = $!
      SendmailMailer.email_notification(@errorMessage).deliver_now
    end
  
    @browser.quit
    
    HitProduct.where('created_at < ?', 10.days.ago).each do |x|
      x.destroy
    end
    
  end

end
