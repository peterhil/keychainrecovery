#!/usr/bin/ruby
#
# Application for brute force cracking a Keychain Access's forgotten password
#

puts "Enter name or path of the keychain to crack:"
keychain = gets

if /^[^\/].+$/.match(keychain)
    keychain = '~/Library/Keychains/' + keychain
    puts "Cracking keychain on path: " + keychain
end

print "Enter the parts of password you can remember.\nReplace the parts you can NOT remember with spaces:\n"
remember = gets

keylength = remember.count(' ')
if remember.index(' ') == nil
    puts "Nothing to do. Quitting"
    exit
else
    @holes = Array.new
    @holes[0] = remember.index(' ')
    keylength.times do |i|
        @holes.push(remember.index(' ', @holes[-1] + 1))
    end
    print @holes, "\n"
end

def trypass(key, keychain)
    print key + "\t"
    system("security unlock-keychain -p #{key} #{keychain}")
    result = $?
    case result
    when 13056 then # Wrong passphrase
        return nil
    when 0 then
        puts "Bingo! The correct password is: ", key
        return true
    else
        puts result
        return result
    end
end

def merge(template, key)
    # Fills the spaces in the template from characters in the key
    @key = key.split(//)
    return template.gsub(' ') {|c| c = @key.shift}
end

def bruteforce(template, keychain)
    keylength = template.count(' ')
    key = 'a' * keylength
    success = false
    #while key.length == keylength or success == true
        guess = merge(template, key)
        success = trypass(guess, keychain)
        key.succ!
    #end
    puts "Congratulations!"
end

trypass('aaa67mica', keychain)
bruteforce(remember, keychain)
