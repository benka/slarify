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
        option :messageLink, :type => :string, :required => false
        option :channel, :type => :string, :required => false
        option :user, :type => :string, :required => false
        option :userIconURL, :type => :string, :required => false
        option :userEmoji, :type => :string, :required => false
     
        def list
            domain = options[:jDomain]
            uriStringJira = "https://#{domain}/rest/api/2/search"
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
                result = JSON.parse(res.body)
                puts result
                puts "ISSUES found: #{result["issues"].count}"
                puts "-------------------------------"
                resultList = ""
                result["issues"].each { |i|
                    puts "KEY: #{i["key"]},  ID: #{i["id"]}"
                    puts "URL: #{i["self"]}"
                    puts "-------------------------------"
                    resultList << "<https://#{domain}/browse/#{i["key"]}|#{i["key"]}>\n"
                }

                if result["issues"].count > 0
                    slackMsg = JSON.parse("{}")

                    options[:user] != nil ? slackMsg["username"] = options[:user] : nil
                    options[:channel] != nil ? slackMsg["channel"] = "\##{options[:channel]}" : nil
                    options[:userIconURL] != nil ? slackMsg["icon_url"] = options[:userIconURL] : nil
                    options[:userEmoji] != nil ? slackMsg["icon_emoji"] = options[:userEmoji] : nil
                    options[:message] != nil ? message = options[:message] : message = "These cards are ready to be verified"
                    options[:messageLink] != nil ? messageLink = options[:messageLink] : messageLink = nil

                    slackMsg["attachments"] = []
                    slackMsg["attachments"][0] = JSON.parse("{}")
                    #slackMsg["attachments"][0]["fallback"] ="#{result["buildState"][0]} &gt; #{result['planName'][0]}"
                    slackMsg["attachments"][0]["title"] = message
                    slackMsg["attachments"][0]["title_link"] = messageLink
                    slackMsg["attachments"][0]["text"] = resultList
                    slackMsg["attachments"][0]["color"] = "#00BFFF"
                    #puts ">>>>>>>>>>>>>>>>>>>>>>"
                    #puts slackMsg
                    #puts ">>>>>>>>>>>>>>>>>>>>>>"

                    uriSlack = URI(options[:sURL])

                    s = Resources::Request.new(uriSlack, nil, nil)
                    sreq = s.create_post_request_header(JSON.generate(slackMsg))

                    sres = Net::HTTP.start(uriSlack.hostname, 
                        :use_ssl => uriSlack.scheme == 'https') { |http|
                        http.request(sreq)
                    }

                    if sres.code != "200"
                        puts sres.code
                    #else
                    #    puts sres
                    end

                end
            end
        end
    end
end