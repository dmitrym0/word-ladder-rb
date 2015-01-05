#!/usr/bin/ruby

require 'logger'
require 'ffi/aspell'
require 'awesome_print'

log = Logger.new(STDOUT)
log.level = Logger::INFO

speller = FFI::Aspell::Speller.new('en_US')

log.debug("Starting!")

class WordLadder
	# Public: class initializer
	# 
	# startWord - the beginning of the lacder
	# endWord - the end of the ladder
	# speller - an object conforming to FFI::Aspell::Speller protocol.
	# log - Ruby Logger
	def initialize(startWord, endWord, speller, log)
		@log = log
		@log.info "Start word: #{startWord} endWord: #{endWord}" if @log

		@startWord = startWord
		@endWord = endWord

		@speller = speller
		@current_shortest_chain = 3

		@considered_words = {}

		@tree  = nil
	end

	# Public: generates a tree of word ladders, can be later consumed by flat_list_of_lists
	# Returns the tree of word ladders
	def generate
		@tree = permuteWord(@startWord, 1) if @tree == nil
	end


	# Public: generates a list of word ladders based on the word ladder tree.
	# Returns an array of arrays (word ladders)
	def flat_list_of_lists
		self.generate if @tree.nil?
		final_queue = Array.new
		flatten(@tree, Array.new, final_queue)
		final_queue
	end

	private

	# Internal: permuteWord in conjuction with recursiveGenerate, creates a tree of word ladders
	def permuteWord(word, depth)
		current_list = []
		(0..word.length-1).each do |index_into_word|
			(0..25).each do | letter_of_alphabet|
				new_word = word.dup # ruby strings are referenced, so lets create a duplicate that we can modify
				new_word[index_into_word] = (letter_of_alphabet + 'a'.ord).chr 
				existing_depth = @considered_words[new_word]
				# check to see whether we've already considered the newly generated word at shallower recursion depth
				if existing_depth.nil? || depth <= existing_depth 
					@considered_words[new_word]	 = depth
					list = recursiveGenerate(new_word, depth)
					if !list.nil? && list.length > 0
						@log.debug "## #{list}"
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

	# Internal:
	def recursiveGenerate(newWord, depth)
		# abandon the search if the depth of the recursion is greater than a previously successful ladder
		if depth > @current_shortest_chain
			return nil
		elsif newWord == @endWord 
			@log.info "Found it at depth #{depth}"
			@current_shortest_chain = depth # now we know the minimum necessary ladder
			return [@endWord]
		elsif @speller.correct?(newWord) # we found a valid word. the possibility for a successful lader remains, recurse.
			@log.debug "Considering #{newWord} at #{depth}"
			return permuteWord(newWord, depth+1)
		end

		@log.debug "~~ not a valid word."
		return nil
	end


	# flattens the @tree, creating an array of word ladders (1D array)
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
			q = flatten(tree[subtree], new_queue, final_queue)
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
