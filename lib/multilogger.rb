require 'logger'

# MultiLogger is an implementation of Ruby logger which can tee the log to
# multiple endpoints.
# This class reeks of :reek:TooManyMethods.
class MultiLogger < Logger
  # Array of loggers to be logged to. These can be anything that acts reasonably
  # like a Logger.
  attr_reader :loggers

  # For things like level and progname, retrieve from the first active logger.
  # There's an implicit assumption that these will be the same across all
  # contained loggers.

  # Logging severity threshold (e.g. <tt>Logger::INFO</tt>).
  def level
    loggers.first.level
  end

  def level=(value)
    loggers.each { |logger| logger.level = value }
  end

  # Program name to include in log messages.
  def progname
    loggers.first.progname
  end

  def progname=(value)
    loggers.each { |logger| logger.progname = value }
  end

  # Set date-time format.
  # +datetime_format+:: A string suitable for passing to +strftime+.
  def datetime_format=(datetime_format)
    loggers.each { |logger| logger.datetime_format = datetime_format }
  end

  # Returns the date format being used.  See #datetime_format=
  def datetime_format
    loggers.first.datetime_format
  end

  # Any method not defined on standard Logger class, just send it on to anyone
  # who will listen.
  # This method reeks of :reek:FeatureEnvy.
  def method_missing(name, *args, &block)
    loggers.each do |logger|
      logger.send(name, args, &block) if logger.respond_to?(name)
    end
  end

  # Returns +true+ iff the current severity level allows for the printing of
  # +DEBUG+ messages.
  def debug?
    loggers.first.level <= DEBUG
  end

  # Returns +true+ iff the current severity level allows for the printing of
  # +INFO+ messages.
  def info?
    loggers.first.level <= INFO
  end

  # Returns +true+ iff the current severity level allows for the printing of
  # +WARN+ messages.
  def warn?
    loggers.first.level <= WARN
  end

  # Returns +true+ iff the current severity level allows for the printing of
  # +ERROR+ messages.
  def error?
    loggers.first.level <= ERROR
  end

  # Returns +true+ iff the current severity level allows for the printing of
  # +FATAL+ messages.
  def fatal?
    loggers.first.level <= FATAL
  end

  #
  # === Synopsis
  #
  #   MultiLogger.new([logger1, logger2])
  #
  # === Args
  #
  # +loggers+::
  #   An array of loggers. Each one gets every message that is sent to the
  #   MultiLogger instance.
  #
  # === Description
  #
  # Create an instance.
  #
  def initialize(loggers)
    @loggers = loggers
  end

  # Methods that write to logs just write to each contained logger in turn
  def add(severity, message = nil, progname = nil, &block)
    loggers.each { |logger| logger.add(severity, message, progname, &block) }
  end
  alias log add

  def <<(msg)
    loggers.each { |logger| logger << msg }
  end

  def debug(progname = nil, &block)
    loggers.each { |logger| logger.debug(progname, &block) }
  end

  def info(progname = nil, &block)
    loggers.each { |logger| logger.info(progname, &block) }
  end

  def warn(progname = nil, &block)
    loggers.each { |logger| logger.warn(progname, &block) }
  end

  def error(progname = nil, &block)
    loggers.each { |logger| logger.error(progname, &block) }
  end

  def fatal(progname = nil, &block)
    loggers.each { |logger| logger.fatal(progname, &block) }
  end

  def unknown(progname = nil, &block)
    loggers.each { |logger| logger.unknown(progname, &block) }
  end

  def close
    loggers.each(&:close)
  end
end # class MultiLogger
