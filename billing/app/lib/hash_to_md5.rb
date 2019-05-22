#  HashToMD5.new({ a: 11, b: 22 }).run
#  => "dfe7b55379f65b255949dfa95863c565"
#  HashToMD5.new({ b: 22, a: 11 }).run
#  => "dfe7b55379f65b255949dfa95863c565"

class HashToMD5
  def initialize(hash)
    @hash = hash.deep_dup
  end

  def run
    Digest::MD5.hexdigest(sigflat(@hash))
  end

  private

  def sigflat(body)
    if body.class == Hash
      arr = []
      body.each do |key, value|
        arr << "#{sigflat key}=>#{sigflat value}"
      end
      body = arr
    end
    if body.class == Array
      str = ''
      body.map! do |value|
        sigflat value
      end.sort!.each do |value|
        str << value
      end
    end
    if body.class != String
      body = body.to_s << body.class.to_s
    end
    body
  end
end
