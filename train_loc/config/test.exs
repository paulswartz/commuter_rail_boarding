use Mix.Config

config :logger,
    backends: [:console]

config :logger, :console,
    level: :info

config :trainloc,
    input_ftp_host: 'localhost',
    input_ftp_user: 'ftpuser',
    input_ftp_password: 'password'
