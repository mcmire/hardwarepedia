
Logging::Rails.configure do |config|

  # Objects will be converted to strings using the :format_as method.
  Logging.format_as :inspect

  # The default pattern used by the appenders.
  pattern = '[%d] %-5l %50c :: %m\n'
  # The default date pattern used by the appenders.
  date_pattern = '%Y-%m-%d %H:%M:%S.%6N'

  # Setup a color scheme called 'bright' than can be used to add color codes
  # to the pattern layout. Color schemes should only be used with appenders
  # that write to STDOUT or STDERR; inserting terminal color codes into a file
  # is generally considered bad form.
  #
  Logging.color_scheme( 'bright',
    :levels => {
      :debug => :green,
      :info  => :green,
      :warn  => :yellow,
      :error => :red,
      :fatal => [:white, :on_red]
    },
    :date => [:blue, :bold],
    :logger => :cyan,
    :message => :white
  )

  # Configure an appender that will write log events to STDOUT. A colorized
  # pattern layout is used to format the log events into strings before
  # writing.
  #
  Logging.appenders.stdout( 'stdout',
    :auto_flushing => true,
    :layout => Logging.layouts.pattern(
      :pattern => pattern,
      :date_pattern => date_pattern,
      :color_scheme => 'bright'
    )
  ) if config.log_to.include? 'stdout'

  # Configure an appender that will write log events to a file. The file will
  # be rolled on a daily basis, and the past 7 rolled files will be kept.
  # Older files will be deleted. The default pattern layout is used when
  # formatting log events into strings.
  #
  Logging.appenders.rolling_file( 'file',
    :filename => config.paths['log'].first,
    :keep => 7,
    :age => 'daily',
    :truncate => false,
    :auto_flushing => true,
    :layout => Logging.layouts.pattern(
      :pattern => pattern,
      :date_pattern => date_pattern
    )
  ) if config.log_to.include? 'file'

  # Configure an appender that will send an email for "error" and "fatal" log
  # events. All other log events will be ignored. Furthermore, log events will
  # be buffered for one minute (or 200 events) before an email is sent. This
  # is done to prevent a flood of messages.
  #
  Logging.appenders.email( 'email',
    :from     => "server@#{config.action_mailer.smtp_settings[:domain]}",
    :to       => "developers@#{config.action_mailer.smtp_settings[:domain]}",
    :subject  => "Rails Error [#{%x(uname -n).strip}]",
    :server   => config.action_mailer.smtp_settings[:address],
    :domain   => config.action_mailer.smtp_settings[:domain],
    :acct     => config.action_mailer.smtp_settings[:user_name],
    :passwd   => config.action_mailer.smtp_settings[:password],
    :authtype => config.action_mailer.smtp_settings[:authentication],

    :auto_flushing => 200,     # send an email after 200 messages have been buffered
    :flush_period  => 60,      # send an email after one minute
    :level         => :error,  # only process log events that are "error" or "fatal"
    :layout        => layout
  ) if config.log_to.include? 'email'

  # Setup the root logger with the Rails log level and the desired set of
  # appenders. The list of appenders to use should be set in the environment
  # specific configuration file.
  #
  # For example, in a production application you would not want to log to
  # STDOUT, but you would want to send an email for "error" and "fatal"
  # messages:
  #
  # => config/environments/production.rb
  #
  #     config.log_to = %w[file email]
  #
  # In development you would want to log to STDOUT and possibly to a file:
  #
  # => config/environments/development.rb
  #
  #     config.log_to = %w[stdout file]
  #
  Logging.logger.root.level = config.log_level
  Logging.logger.root.appenders = config.log_to unless config.log_to.empty?

end

