module Slarify
    module Resources

        class Jira

            def initialize(uri, user, pwd)
                @uri = uri
                @user = user
                @pwd = pwd
            end

            def search_cards(jql)
                puts ">>> #{jql}"
=begin                
                filter=options[:filter_name]
                domain=options[:domain]
                uriString = "https://#{domain}/rest/api/2/search"
                uri = URI(uriString)
                jql = options[:jql]

                r = Resources::Request.new(uri, options[:user], options[:pwd])
                req=r.create_post_request_header(jql)

                res = Net::HTTP.start(uri.hostname, 
                    :use_ssl => uri.scheme == 'https') { |http|
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
                        if options[:transition] 
                            t = Resources::Transition.new(options[:user], options[:pwd])
                            t.get_transitions(i["self"], options[:transition])
                        end
                    }
                end
=end

            end


            def get_issues(searchUrl)
                list_issues(searchUrl, false, false)

            end

            def transition_issues(searchUrl, transition)
                list_issues(searchUrl, true, transition)
            end

            def list_issues(searchUrl, do_transition, transition)
                uri = URI("#{searchUrl}&maxResults=200")
                r = Resources::Request.new(uri, @user, @pwd)
                req=r.create_get_request_header

                res = Net::HTTP.start(uri.hostname, 
                    :use_ssl => uri.scheme == 'https') { |http|
                    http.request(req)
                }

                if res.code != "200"
                    puts res.code
                    puts res.message
                else 
                    result=JSON.parse(res.body)
                    puts "Number of issues: #{result["issues"].count}"                    
                    result["issues"].each { |i| 
                        puts "Issue KEY: #{i["key"]},  ID: #{i["id"]}"
                        puts "URL: #{i["self"]}"
                        puts "-------------------------------"
                        if do_transition
                            t = Resources::Transition.new(@user, @pwd)
                            t.get_transitions(i["self"], transition)
                        end
                    }
                end
            end
        end
    end
end


