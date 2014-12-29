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
		@log.info "Start word: #{startWord} endWord: #{endWord}" if @log

		@startWord = startWord
		@endWord = endWord

		@speller = speller
		@current_shortest_chain = 3

		@considered_words = {}
	end

	def generate
		return self.permuteWord(@startWord, 1)
	end


	def permuteWord(word, depth)
		current_list = []
		temp_word = word.dup
		(0..temp_word.length-1).each do |index_into_word|
			(0..25).each do | letter_of_alphabet|
				new_word = word.dup
				new_word[index_into_word] = (letter_of_alphabet + 'a'.ord).chr
				existing_depth = @considered_words[new_word]
				if existing_depth.nil? || depth <= existing_depth
					@considered_words[new_word]	 = depth
					list = recursiveGenerate(new_word, depth)
					if !list.nil? && list.length > 0
						@log.debug "## #{list}"
						neww = new_word
						list.unshift(word)
						current_list.push list
					end
				else 
					@log.debug "~~ Considered already"
				end
			end			
		end
		@log.debug "Prior to return, considered word was #{word}"
		return current_list
	end

	def recursiveGenerate(newWord, depth)
		if depth > @current_shortest_chain
			return nil
		elsif newWord == @endWord 
			@log.info "Found it at depth #{depth}"
			current_shortest_chain = depth
			return [@endWord]
		elsif @speller.correct?(newWord)
			@log.debug "Considering #{newWord} at #{depth}"
			return permuteWord(newWord, depth+1)
		end

		@log.debug "~~ not a valid word."
		return nil
	end

end



ladder = WordLadder.new("hit", "cog", speller, log)
result = ladder.generate
puts "Result: #{result}"
ap result
