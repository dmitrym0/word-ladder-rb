#!/usr/bin/ruby

require 'logger'
require 'ffi/aspell'
require 'awesome_print'

log = Logger.new(STDOUT)
log.level = Logger::INFO

speller = FFI::Aspell::Speller.new('en_US')

log.debug("Starting!")

class WordLadder
	def initialize(startWord, endWord, speller, log = nil)
		@log = log
		@log.debug "Start word: #{startWord} endWord: #{endWord}" if @log

		@startWord = startWord
		@endWord = endWord

		@speller = speller
		@current_shortest_chain = 100

		@considered_words = Hash.new(0)
	end

	def generate
		return self.permuteWord(@startWord, @endWord)
	end


	def permuteWord(word, depth = nil)
		@log.debug "- Considering #{word}"
		current_list = []
		temp_word = word.dup
		(0..temp_word.length-1).each do |index_into_word|
			(0..25).each do | letter_of_alphabet|
				new_word = word.dup
				new_word[index_into_word] = (letter_of_alphabet + 'a'.ord).chr
				unless @considered_words.has_key?(new_word)
					@considered_words[new_word]	 = 1
					list = recursiveGenerate(new_word)
					if !list.nil? && list.length > 0
						@log.debug "## #{list}"
						neww = new_word
						list.unshift(word)
						current_list.push list
					end
				else 
					@log.debug "~~ Considered already"
				end

				@considered_words[word] = 1
			end			
		end
		@log.debug "Prior to return, considered owrd was #{word}"
		return current_list
	end

	def recursiveGenerate(newWord, depth = nil)
		@log.debug(newWord)
		if newWord == @endWord 
			@log.info "Found it!"
			return [@endWord]
		elsif @speller.correct?(newWord)
			@log.debug "Considering #{newWord}"
			return permuteWord(newWord)
		end

		@log.debug "~~ not a valid word."
		return nil
	end

end



ladder = WordLadder.new("hit", "cog", speller, log)
puts "Result: #{ladder.generate}"