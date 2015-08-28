require 'net/http'
require 'nokogiri'
require 'json'
require 'twilio-ruby'

HOST = "mailchimp.com"
PATH = "/replyall/"
TITLE_FILE = "mailchimp"
ALERTEES_FILE = "alertees.json" # this will need to be manually created

def get_saved_title()
  begin
    return File.read(TITLE_FILE).strip!
  rescue => e
    return ""
  end
end

def get_mailchimp_title_text()
  begin
    mailchimp_html = Net::HTTP.get(HOST, PATH)
  rescue e
    puts "Something went wrong with a web request...\n" + exception.backtrace
    raise e
  end

  return Nokogiri::XML(mailchimp_html).at('h1').text
end

def save_new_title(title)
  File.open(TITLE_FILE, 'w').puts(title)
end

def get_alertees_from_file()
  json_string = File.read(ALERTEES_FILE).strip!
  return JSON.parse(json_string)
end

def alert_da_masses()
  account_sid = ENV["TWILIO_ACCOUNT_SID"]
  auth_token = ENV["TWILIO_AUTH_TOKEN"]
  twilio = Twilio::REST::Client.new(account_sid, auth_token)
  from = ENV["TWILIO_NUMBER"]
  alertees = get_alertees_from_file()

  alertees.each do |key, value|
    twilio.account.messages.create(
      :from => from,
      :to => key,
      :body => "- -\n\nFREDDIE ALERT!!!\n\nHurry and get your fresh new Freddie here: mailchimp.com/replyall"
    )
    puts "Sent alert to #{value}"
  end
end

###

old_mailchimp_title = get_saved_title()
new_mailchimp_title = get_mailchimp_title_text()

if old_mailchimp_title.empty?
  save_new_title(new_mailchimp_title)
elsif old_mailchimp_title != new_mailchimp_title
  alert_da_masses()
  save_new_title(new_mailchimp_title)
end
