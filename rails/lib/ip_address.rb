# Copyright 2010 The Apache Software Foundation.
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
# http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# code from http://www.prfsa.com/post.rhtml?title=ruby-ip-address-class-part-2
# example code:
#
# ip = IpAddress.new("10.0.0.1")
# puts "Address: #{ip} (version #{ip.version})"
#  => Address: 10.0.0.1 (version 4)
#
# ip = IpAddress.new(156763422792541232312137643, 6)
# puts "Address: #{ip} (version #{ip.version})"
#  => Address: 0000:0000:0081:abf2:2d8a:a5bf:cf88:b7ab (version 6)

class IpAddress
  IP_MAX = {4 => (1 << 32) - 1, 6 => (1 << 128) - 1}
  IP_BITS = {4 => 32, 6 => 128}

  # Takes an Integer or a String representation of an IP Address and coerces it
  # to a representation of the requested type (:integer / :string). If the
  # version (4/6) is not specified then it will be guessed with guess_version.
  def self.coerce(value, to_type, version = nil)
    raise "unknown type #{to_type.inspect} requested" unless
      [:integer, :string].include?(to_type)
    version ||= guess_version(value)
    
    case value
    when Integer
      if to_type == :integer then value
      elsif version == 4
        [24, 16, 8, 0].map { |shift| (value >> shift) & 255 }.join(".")
      else sprintf("%.32x", value).scan(/.{4}/).join(":")
      end
    when String
      if to_type == :string then value
      elsif version == 4
        value.split(".").inject(0) { |total, octet| (total << 8) + octet.to_i }
      else value.delete(":").to_i(16)
      end
    end
  end

  # Takes an Integer or a String and guesses whether it represents an IPv4 or
  # IPv6 address. For an Integer, IPv4 is assumed unless the value is greater
  # than IP_MAX[4]. For a String, IPv6 is assumed if it contains at least one
  # colon (:).
  def self.guess_version(value)
    case value
    when Integer then value > IP_MAX[4] ? 6 : 4
    when String then value =~ /:/ ? 6 : 4
    end
  end

  attr_reader :integer, :string, :version

  # Takes an Integer or a String representation of an IP Address and creates a
  # new IpAddress object with it. If the version (4/6) is not specified then it
  # will be guessed with guess_version.
  def initialize(value, version = nil)
    @version = version || IpAddress.guess_version(value)
    @integer = IpAddress.coerce(value, :integer, @version)
    @string = IpAddress.coerce(value, :string, @version)
  end

  def to_i; @integer; end

  def to_s; @string; end

  # Adds the specified Integer value to that of the IpAddress and returns a new
  # IpAddress based on the sum.
  def +(value)
    IpAddress.new(@integer + value, @version)
  end
  
  # Subtracts the specified Integer value from that of the IpAddress and returns
  # a new IpAddress based on the difference.
  def -(value)
    IpAddress.new(@integer - value, @version)
  end
  
  # Returns the next IpAddress after this one.
  def succ
    self + 1
  end
  
  include Comparable      
  
  # Compares one IpAddress with another based on the Integer representation of
  # their values.
  def <=>(other)
    @integer <=> other.integer
  end
  
  # Takes an Integer or a String representation of a network mask and returns
  # the range of IpAddresses in that network.
  def mask(value)
    base_int = @integer & IpAddress.coerce(value, :integer, @version)
    Range.new(IpAddress.new(base_int, @version),
	      IpAddress.new(base_int + IpAddress.mask_size(value, @version) - 1))
  end
  
  
  # Takes an Integer or a String representation of a network mask and returns the
  # number of addresses it encodes. If the version (4/6) is not specified then it
  # will be guessed with guess_version.
  def self.mask_size(value, version = nil)
    version ||= guess_version(value)
    (coerce(value, :integer, version) ^ IP_MAX[version]) + 1
  end
  
  # Takes an Integer bitcount (bits) and returns an appropriate masking Integer.
  # For example, a /24 network (in IPv4) corresponds to a mask of 255.255.255.0 
  # or the number 4294967040. If the version (4/6) is not specified then it will
  # be assumed to be 4 unless bits > 32.
  def self.mask_from_slash_bits(bits, version = nil)
    raise "bits > 128" if bits > 128
    version ||= bits > 32 ? 6 : 4
    
    max = IP_MAX[version]
    left_shift = IP_BITS[version] - bits
    (max << left_shift) & max
  end
  
  # Returns the range of IpAddresses in the specified /bits network. Basically a
  # convenience wrapper around mask.
  def /(bits)
    mask(IpAddress.mask_from_slash_bits(bits, @version))
  end
  
  def dig
    open("|/usr/bin/dig -x #{self.to_s} +short") {|f| f.readlines.join("\n") }
  end
end

class Integer
  def to_ip(version = nil)
    IpAddress.new(self, version)
  end
end

class String
  def to_ip(version = nil)
    if self =~ /^([\da-f]{4}\:){7}[\da-f]{4}$/ or self =~ /^([\d]{1,3}\.){3}[\d]{1,3}$/ 
      return IpAddress.new(self, version)
    end
    #    if self =~ /^([\da-f]{4}\:){7}[\da-f]{4}$/ 
    # todo for ipv6    
    #    end
    if self =~ /^(([\d]{1,3}\.){3}[\d]{1,3})\/(\d{1,2})$/ 
      return IpAddress.new($1) / $3.to_i
    end
    raise "'#{self}' is not an IP address."
  end
end
