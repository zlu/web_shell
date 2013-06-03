require 'sinatra'
require 'sinatra/reloader' if development?
require 'open3'

get '/' do
  if params[:cmd]
    cmd_string = params[:cmd].split
    cmd = cmd_string.shift
    if cmd == 'clear'
      system "mv log log.#{Time.now.to_i}; touch log"
      redirect to '/'
    end

    File.open('log', 'a+') do |file|
      file.puts Time.now.to_s + " - " + params[:cmd]
      if ['sudo', 'rm', 'kill'].include? cmd
        file.puts "ERROR: You are not authorized to issue #{cmd}"
      else
        begin
          Open3.popen3(cmd, *cmd_string) do |i, o, e, t|
            file.puts o.read
            file.puts "WARN: " + e.read unless e.read.empty?
          end
        rescue Exception => error
          file.puts "ERROR: " + error.message
        end
      end
    end
  end

  erb :home
end


