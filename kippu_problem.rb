# Kippu problem
#
# written by Akinori MUSHA, Dec 12 2001
#
# Usage: ruby kippu_problem.rb <goal number> <number1> <number2> ...

class Expr
  attr_reader :value, :stack

  ADD = '+'.intern
  SUB = '-'.intern
  MUL = '*'.intern
  DIV = '/'.intern

  Operators = [
    ADD, SUB, MUL, DIV
  ]

  def initialize(value, stack = [value])
    @stack = stack
    @value = value
  end

  def operate(op, expr)
    value = \
    case op
    when ADD
      @value + expr.value
    when SUB
      @value - expr.value
    when MUL
      @value * expr.value
    when DIV
      Rational(@value) / expr.value
    end

    stack = @stack + expr.stack
    stack.push(op)

    return Expr.new(value.denominator == 1 ? value.numerator : value, stack)
  end

  def ==(x)
    case x
    when Expr
      @value == x.value && @stack == x.stack
    else
      @value == x
    end
  end

  def _paren(x)
    x.is_a?(String) ? "(#{x})" : x
  end 

  def inspect
    if false
      # RPN
      @stack.join(' ') + ' = ' + @value.to_s
    else
      stack = []

      @stack.each { |x|
	case x
	when Symbol
	  b, a = stack.pop, stack.pop
	  stack.push([_paren(a), x, _paren(b)].join(' '))
	else
	  stack.push(x)
	end
      }

      stack[0] + ' = ' + @value.to_s
    end
  end
end

def solve(goal, exprs, &block)
  case n = exprs.size
  when 0
    puts 'No numbers given.'
  when 1
    if exprs[0] == goal
      if block
	return block.call(exprs[0])
      else
	return false
      end 
    end
  else
    for i in 0..(n - 2)
      a = exprs[i]

      for j in (i + 1)..(n - 1)
	texprs = exprs.dup
	b = texprs.slice!(j) # assuming i < j

	Expr::Operators.each { |op|
	  begin
	    e = a.operate(op, b)
	    texprs[i] = e
	    ret = solve(goal, texprs, &block) and return ret
	  rescue ZeroDivisionError
	  end

	  begin
	    e = b.operate(op, a)
	    texprs[i] = e
	    ret = solve(goal, texprs, &block) and return ret
	  rescue ZeroDivisionError
	  end
	}
      end
    end
  end

  return false
end

def main(goal, *nums)
  goal = goal.to_i
  exprs = nums.map { |s| Expr.new(s.to_i) }

  solutions = []

  solve(goal, exprs) { |sol|
    s = sol.inspect
    solutions << s unless solutions.include?(s)
    false	# return true if you want to abort when a solution is found
  }
  
  puts solutions
end

main(*ARGV)
