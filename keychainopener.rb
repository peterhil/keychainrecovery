#!/usr/bin/ruby

# Created: 2005/01/15
# Author: Peter Hillerström

# An application to recover a lost keychain password with brute force method.

# 39901 kokeilun jälkeen löytyi! :-D

class Bruteforce
  
  $prompt = ">>> "
  
  def init
    l = ('a'..'z')
    u = 'A'..'Z'
    n = (0..9)
    s = []
    puts l
  end

  def getKeychain
    print "Enter name or path of the keychain to crack:\n" + $prompt
    keychain = gets
    if /^[^\/].+$/.match(keychain)
      keychain = '~/Library/Keychains/' + keychain
    end
    puts "Cracking keychain on path: " + keychain + "\n"
    return keychain
  end

  def getTemplate
    puts "Enter the parts of the password you can remember."
    puts "Replace the characters you can't remember with spaces."
    print "Just press enter if can't remember anything:\n" + $prompt
    template = gets.chomp
    keylength = template.count(' ')

    # Can't remember any characters, use a blank template of certain length
    if template == ""
      defKeylength = 8
      print "How long the password was? [#{defKeylength}]\n" + $prompt
      keylength = gets.to_i
      if keylength == 0
        keylength = defKeylength 
      end
      template = " " * keylength
    end

    # No holes (spaces) in template so exit
    if template.index(' ') == nil
      puts "Nothing to do. Quitting."
      exit
    end

    return template
  end

  def splitTemplate(template)
    return template.split(/ /)
  end

  def merge(template, key)
    # Fills the spaces in the template from characters in the key
    @key = key.split(//)
    return template.gsub(' ') {|c| c = @key.shift}
  end

  def holes
    keylength = remember.count " "
    if remember.index(' ') == nil
      print "Nothing to do. Quitting"
      exit
    else
      @holes = Array.new
      @holes[0] = remember.index(' ')
      keylength.times do |i|
        @holes.push(remember.index(' ', @holes[-1] + 1))
      end
      print @holes, "\n"
    end
  end

  def trypass(key, keychain)
    print key + "\t"
    system("security unlock-keychain -p #{key} #{keychain}")
    result = $?
    case result
    when 13056 then # Wrong passphrase
      puts "Wrong!"
      return false
    when 0 then
      puts "Bingo! The correct password is: ", key
      puts "Congratulations!"
      return true
    when 12800 then # Keychain not found
      puts "Error #{result}: The specified keychain could not be found. Quitting."
      exit result
    when 32256 then # Permission denied
      puts "Error #{result}: Permission denied. Quitting."
      exit result
    when 32512 then # No such file or directory
      puts "Error #{result}: No such file or directory. Quitting."
      exit result
    else
      puts result
      exit result
    end
  end

  def bruteforce(template, keychain)
      keylength = template.count(' ')
      key = 'a' * keylength
      #key = 'aaa'
      success = false
      $defSTDERR = STDERR
      STDERR.reopen("/dev/null")
      while success == false and key.length == keylength
          guess = merge(template, key)          
          success = trypass(guess, keychain)
          key.succ!
      end
      STDERR.reopen($defSTDERR)
  end

end
# End lib

Opener = Bruteforce.new
keychain = Opener.getKeychain
template = Opener.getTemplate
Opener.bruteforce(template, keychain)