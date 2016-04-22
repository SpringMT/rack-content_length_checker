require 'logger'

module Rack
  class ContentLengthChecker
    # @param app []
    # @param logger [] logger
    # @param options [Hash] opts チェックするオプション
    # @option opts [Symbol] :warn lenght と 例外を排出するかの
    # @option opts [Symbol] :fatal lenght と 例外を排出するかの
    # @return Object
    def initialize(app, warn: {}, fatal: {}, logger: ::Logger.new(STDOUT))
      @app    = app
      @logger = logger
      @warn   = warn
      @fatal  = fatal
      @warn_length = @warn[:length].to_i
      @fatal_length = @fatal[:length] ? @fatal[:length].to_i : Float::INFINITY
      raise ArgumentError, 'warn length is greater than 0'  if @warn_length < 0
      raise ArgumentError, 'fatal length is greater than 1' if @fatal_length < 1
      raise ArgumentError, 'Warn length is smaller than fatal one.' if ((!@fatal.empty?) && (@warn[:length].to_i > @fatal[:length].to_i))
    end

    def call(env)
      request_length = env['CONTENT_LENGTH'].to_i

      error_status  = 413
      error_headers = {'Content-Type' => 'text/plain'}
      error_body    = "Request Entity Too Large : #{request_length} bytes"
      error_message = "remote_addr:#{env['HTTP_X_FORWARDED_FOR']}\tmethod:#{env['REQUEST_METHOD']}\turi:#{env['REQUEST_URI']}\tmsg:#{error_body}"

      case request_length
      when @warn_length..@fatal_length-1
        unless @warn.empty?
          @logger.warn(error_message)
          return [error_status, error_headers, [error_body]] if @warn[:is_error]
        end
      when @fatal_length..Float::INFINITY
        unless @fatal.empty?
          @logger.fatal(error_message)
          return [error_status, error_headers, [error_body]] if @fatal[:is_error]
        end
      end
      status, headers, body = @app.call(env)
      [status, headers, body]
    end
  end
end
