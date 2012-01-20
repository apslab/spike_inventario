class Oauth::Applications
  
  @@loaded = false

  def initialize
    raise <<-INFO
      This class can't be initialize.
      You can use:
        Oauth::Applications.by_name(name)
        Oauth::Applications.by_identifier(identifier)
        Oauth::Applications.reload
        Oauth::Applications.show_credentials
    INFO
  end

  
  def self.by_name(name)
    apps_by_name[name]
  end

  def self.by_identifier(identifier)
    apps_by_identifier[identifier]
  end

  def self.reload
    load_properties(false)
  end

  def self.show_credentials
    apps_by_name.values.map { |credential| credential }.join("\n")
  end

  class Credential
    attr_reader :app_name, :identifier, :secret

    def initialize(app_name, identifier, secret)
      @app_name = app_name
      @identifier = identifier
      @secret = secret
    end

    def to_s
      "#{app_name}:\n\tIdentifier: #{identifier}\n\tSecret: #{secret}"
    end
  end

  private

  def self.apps_by_name
    load_properties
    @@apps_by_name
  end

  def self.apps_by_identifier
    load_properties
    @@apps_by_identifier
  end

  # Carga los datos obtenidos de config/services.yml
  # El parametro de este método determina si se debe verificar que ya se encuentran cargados los datos. Si
  # se omite o es true, entonces utilizará los datos mas cargados. Si el parámetro es false entonces se
  # vuelven a tomar los datos del archivo.
  def self.load_properties(check_already_load = true)
    return if check_already_load && @@loaded
    @@loaded = true
    @@apps_by_name, @@apps_by_identifier = {}, {}
    YAML.load_file("#{Rails.root.to_s}/config/services.yml")[Rails.env].each do |app_name, keys|
      credential = Credential.new(app_name, keys['identifier'], keys['secret'])
      @@apps_by_name[credential.app_name] = credential
      @@apps_by_identifier[credential.identifier] = credential
    end 
  end

end
