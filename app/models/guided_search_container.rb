class GuidedSearchContainer
  FIELD_NAMES = [:identifier, :title, :subject, :description, :genre, :relation,
    :coverage, :audience_level, :audience_rating, :creator, :contributor,
    :publisher, :rights, :extension, :location, :annotation, :date]

  attr_accessor :full_text

  def initialize(params = nil)
    @fields = params.nil? ?
      HashWithIndifferentAccess.new :
      HashWithIndifferentAccess.new(params.to_hash)
    self.full_text = @fields.delete(:full_text)
  end

  def self.from_string(query_string)
    if query_string.nil?
      h = nil
    else
      args = query_string.split(/ *@/)
      h = { :full_text => args.shift }
      args.each do |arg|
        key, value = arg.split(/ +/, 2)
        h[key] = value
      end
    end
    GuidedSearchContainer.new(h)
  end

  def to_s
    query = [full_text] + @fields.map{|k,v| (FIELD_NAMES.include?(k.to_sym) && !v.empty?) ? "@#{k.to_s} #{v}" : nil}
    query = query.select{|x| !(x.nil? || x.empty?)}
    query.join(" ")
  end

  def method_missing(method, *args)
    if FIELD_NAMES.include?(method.to_sym)
      @fields[method]
    elsif (method.to_s[-1] == 61 && FIELD_NAMES.include?(method.to_s[0..-2].to_sym))
      @fields[method.to_s[0..-2]] = args[0]
    else
      super(method, *args)
    end
  end

  def respond_to?(method)
    FIELD_NAMES.include?(method.to_sym) ||
      (method.to_s[-1] == 61 && FIELD_NAMES.include?(method.to_s[0..-2].to_sym)) ||
      super(method)
  end
end