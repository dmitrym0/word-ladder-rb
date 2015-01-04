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

		@tree  = nil
	end

	def generate
		@tree = self.permuteWord(@startWord, 1) if @tree == nil
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
						current_list.push word if current_list.length == 0
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

	def flat_list_of_lists
		self.generate if @tree.nil?
		final_queue = Array.new
		self.flatten(@tree, Array.new, final_queue)
		final_queue
	end

	def flatten(tree, current_queue, final_queue)
		@log.debug "tree=#{tree} current_queue=#{current_queue}"
		if tree.length == 1 
			current_queue.push(tree[0])
			@log.debug "+++ #{current_queue}"
			final_queue.push(current_queue.flatten)
		end

		current_queue.push(tree[0])
		list_of_queues = Array.new
		(1..tree.length-1).each do | subtree |
			new_queue = current_queue.dup
			q = self.flatten(tree[subtree], new_queue, final_queue)
			@log.debug("Returned queue is #{q}")
			list_of_queues.push(q)
		end
		return list_of_queues	
	end
end



ladder = WordLadder.new("hit", "cog", speller, log)
ap ladder.generate
result = ladder.flat_list_of_lists
puts "Result: #{result}"
ap result
