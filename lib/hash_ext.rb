class Hash
  def keep_keys(key_list)
    self.each_key { |key| delete(key) unless key_list.map{|k| k.to_s }.member? key.to_s }
  end
end
