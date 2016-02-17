require "slarify/version"
require "slarify/res/request"
require "slarify/res/jira"


require "net/http"
require "xmlsimple"
require "json"
require "thor"

require 'rss'
require 'open-uri'


module Slarify
    
    ##include Resoures
    puts "Slarify - Slack about JIRA cards"
    puts "Version #{VERSION}"

    class Slarify < Thor

        # posts a message to Slack
        # options
        desc "list", "posts a message to Slack listing JIRA cards that fulfill the JIRA query"
        option :sURL, :type => :string, :required => true
        option :jDomain, :type => :string, :required => true
        option :jUser, :type => :string, :required => true
        option :jPass, :type => :string, :required => true
        option :jql, :type => :string, :required => true
        option :message, :type => :string, :required => false
        option :channel, :type => :string, :required => false
        option :failedChannel, :type => :string, :required => false
        option :user, :type => :string, :required => false
        option :userIconURL, :type => :string, :required => false
        option :userEmoji, :type => :string, :required => false
     
        def message
            uriStringJira = "https://#{options[:jDomain]}/rest/api/2/search"
            uriJira = URI(uriStringJira)

            r = Resources::Request.new(uriJira, options[:jUser], options[:jPass])
            req = r.create_post_request_header(options[:jql])

            res = Net::HTTP.start(uriJira.hostname, 
                :use_ssl => uriJira.scheme == 'https') { |http|
                http.request(req)
            }

            if res.code != "200"
                puts res.code
                puts res.message
            else 
                result=JSON.parse(res.body)
                puts "ISSUES found: #{result["issues"].count}"
                puts "-------------------------------"
                result["issues"].each { |i|
                    puts "KEY: #{i["key"]},  ID: #{i["id"]}"
                    puts "URL: #{i["self"]}"
                    puts "-------------------------------"
                }
=begin
                result = XmlSimple.xml_in res.body
                #puts result.keys
               
                puts result["key"]
                puts result['planName'][0]
                puts result["projectName"][0]
                puts result["buildNumber"][0]
                puts result["buildState"][0]
                reasonSummary = result["reasonSummary"][0].gsub! "a href=\"", ""
                reasonSummary = reasonSummary.gsub! "\">", "|"
                reasonSummary = reasonSummary.gsub! "</a>", ">"
                puts result["reasonSummary"]

                slackMsg = JSON.parse("{}")

                options[:user] != nil ? slackMsg["username"] = options[:user] : nil
                options[:channel] != nil ? slackMsg["channel"] = "\##{options[:channel]}" : nil
                options[:userIconURL] != nil ? slackMsg["icon_url"] = options[:userIconURL] : nil
                options[:userEmoji] != nil ? slackMsg["icon_emoji"] = options[:userEmoji] : nil

                rand = Random.new

                emojiSuccess = [":white_check_mark:", ":eight_spoked_asterisk:", ":bowtie:", ":sunglasses:", ":+1:"]
                emojiFail = [":trollface:", ":bangbang:", ":x:", ":do_not_litter:", ":x:", ":no_entry_sign:", ":no_entry:", ":sos:"]
                
                if (result["buildState"][0] == "Failed")
                    resultEmoji = emojiFail[rand.rand(emojiFail.length)]
                    resultColor = "#E02D19"
                    options[:failedChannel] != nil ? slackMsg["channel"] = "\##{options[:failedChannel]}" : nil
                else
                    resultEmoji = emojiSuccess[rand.rand(emojiSuccess.length)] 
                    resultColor = "#0DB542"
                end

                #slackMsg["text"] = "> #{resultEmoji} <https://#{bambooURL}/builds/browse/#{result["key"]}|#{result["projectName"][0]} &gt; #{result['planName'][0]} &gt; #{result["buildNumber"][0]} > *#{result["buildState"][0]}*\n> #{result["reasonSummary"][0]}"
                slackMsg["attachments"] = []
                slackMsg["attachments"][0] = JSON.parse("{}")
                #slackMsg["attachments"][0]["fallback"] ="#{resultEmoji} <https://#{bambooURL}/builds/browse/#{result["key"]}|#{result["projectName"][0]} &gt; #{result['planName'][0]} &gt; #{result["buildNumber"][0]} > *#{result["buildState"][0]}*\n> #{result["reasonSummary"][0]}"
                slackMsg["attachments"][0]["fallback"] ="#{result["buildState"][0]} &gt; #{result['planName'][0]}"
                #slackMsg["attachments"][0]["pretext"] = "#{resultEmoji} #{result['planName'][0]}"
                slackMsg["attachments"][0]["title"] = "#{result["projectName"][0]} &gt; #{result['planName'][0]}"
                slackMsg["attachments"][0]["title_link"] = "https://#{bambooURL}/builds/browse/#{result["key"]}"
                slackMsg["attachments"][0]["fields"] = []
                slackMsg["attachments"][0]["fields"][0] = JSON.parse("{}")
                slackMsg["attachments"][0]["fields"][0]["title"] = result["buildState"][0]
                slackMsg["attachments"][0]["fields"][0]["value"] = "Build number: #{result["buildNumber"][0]}"
                slackMsg["attachments"][0]["fields"][0]["short"] = true
                slackMsg["attachments"][0]["fields"][1] = JSON.parse("{}")
                slackMsg["attachments"][0]["fields"][1]["title"] = "Reason:"
                slackMsg["attachments"][0]["fields"][1]["value"] = result["reasonSummary"][0]
                slackMsg["attachments"][0]["fields"][1]["short"] = true
                slackMsg["attachments"][0]["color"] = resultColor
                puts ">>>>>>>>>>>>>>>>>>>>>>"
                puts slackMsg
                puts ">>>>>>>>>>>>>>>>>>>>>>"

                #options[:message] != nil ? msg = options[:message] : nil

                slackURL=options[:sURL]
                uriStringSlack = slackURL
                uriSlack = URI(uriStringSlack)

                s = Resources::Request.new(uriSlack, nil, nil)
                sreq = s.create_post_request_header(JSON.generate(slackMsg))

                sres = Net::HTTP.start(uriSlack.hostname, 
                    :use_ssl => uriSlack.scheme == 'https') { |http|
                    http.request(sreq)
                }
                if sres.code != "200"
                    puts sres.code
                else
                    puts sres
                end
=end
            end
        end
    end
end