require 'yaml'
require 'httparty'

def get_list_of_packages(bioc=true, release=false)
    auth = {:username => "readonly", :password => "readonly"}
    yaml = HTTParty.get('https://hedgehog.fhcrc.org/bioconductor/trunk/bioconductor.org/config.yaml',
      :basic_auth => auth).to_s
    fio = StringIO.new(yaml)
    config = YAML.load_stream(fio).first

    if release
      version = config['release_version']
      branch = "branches/RELEASE_#{version.sub('.', '_')}"
    else
      version = config['devel_version']
      branch = 'trunk'
    end

    if bioc
      repos = 'bioconductor'
      extra = 'madman/Rpacks'
      manifest_file = "bioc_#{version}.manifest"
    else
      repos = 'bioc-data'
      extra = 'experiment/pkgs'
      manifest_file = "bioc-data-experiment.#{version}.manifest"
    end


    url = "https://hedgehog.fhcrc.org/#{repos}/#{branch}/#{extra}/#{manifest_file}"
    resp = HTTParty.get(url, :basic_auth => auth)
    resp.to_s.split("\n").find_all{|i| i =~ /^Package:/}.map{|i| i.sub("Package:", "").strip}.sort_by{|i|i.downcase}
end