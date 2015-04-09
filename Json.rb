#Gramatyka języka JSON
# object 	: LB exp RB ;
# exp 		: key Colon value exp | 'null';
# key 		: Apos Chars Apos ;
# value 	: key back | Digits back | object back | table back | doub back ;
# back		: Coma | 'null' ;
# table 	: LTb tb_cont RTb ;
# tb_cont 	: value tb_cont | 'null' 
# Digits 	: ('0'|'1'|'2'|'3'|'4'|'5'|'6'|'7'|'8'|'9')+ ;
# Chars 	: [A-Za-z]+ ;
# doub		: Digits Dot Digits ;
# Apos		: '\u0022' ; // "
# LB 		: '\u007B' ; // {
# RB 		: '\u007D' ; // }
# LTb		: '\u005B' ; // [
# RTb		: '\u005D' ; // ]
# Colon		: '\u003A' ; // :
# Dot		: '\u002E' ; // .
# Coma 		: '\u002C' ; // ,
# WS 		: [ \t\r\n]+ -> skip ;
# ----------------------------------------------------------------------------


json = %Q({ 
    "title": "Product",
    "description": "A product from Acme's catalog",
    "type":"object",
    "properties": {
        "id": {
            "description": "The unique identifier for a product",
            "type": "integer"
        },
        "name": {
            "description": "Name of the product",
            "type": "string"
        },
        "price": {
            "type": "number",
            "minimum": 0,
            "exclusiveMinimum": 43
        },
        "tags": {
            "type": "array",
            "items": {
                "type": "string"
            },
            "minItems": 1,
            "uniqueItems": 23
        }
    },
    "required": ["id", "name", "price"]
})

@tab = json.split(" ").join.split(//)
@i = 0

def show_errors
	# Metoda wyswietlajaca bledy
	"\nNr błędnego znaku: " + "#{@i + 1}" + "\n" + " ^ " + "#{@tab[@i, 30].join}"
end

def inc	
	# Metoda inkrementujaca
	@i = @i + 1
end

def key
	# key 		: Apos Chars Apos ;	
	if @tab[@i] == '{'
		inc()
	end

	if @tab[@i] == '"'
		inc()
	else
		abort('Brak " w definicji klucza' + "#{show_errors}")
	end
	chars()
	if @tab[@i] == '"'
		inc()
	else
		abort('Brak " w definicji klucza' + "#{show_errors}")
	end
end

def chars
	if @tab[@i] =~ /[A-Za-z']/
		inc()
		chars()
	end
end


def liter
	if @tab[@i] == '"'
		inc()
	end
		chars()
	if @tab[@i] == '"'
		inc()		
	end
end

def numbers
	if @tab[@i] =~ /[0-9]/
		inc()
		numbers()
	end
end

def tabcheck
	# tb_cont 	: value tb_cont | 'null' 
	if @tab[@i] == '"'
		liter
	elsif @tab[@i] =~ /[0-9]/
		numbers()
	end
end

def tab
	# table 	: LTb tb_cont RTb ;
	inc()
	tabcheck()
	if @tab[@i] == ']'
		inc()
	elsif @tab[@i] == ','
		tab()
	else
		abort("Błąd domknięcia tablicy - Brak ]" + "#{show_errors}")
	end
end

def value
	# value 	: key back | Digits back | object back | table back | doub back ;
	if @tab[@i] == '"'	
		liter()
	elsif @tab[@i] =~ /[0-9]/
		numbers()
	elsif @tab[@i] == '['
		tab()
	elsif @tab[@i] == '{'
		obj()
	else 
		abort("Błąd definicji wartości obiektu" + "#{show_errors}")
	end
	if @tab[@i] == '}'
		inc()		
	end
	if @tab[@i] == ','
		exp()
	end
end

def exp
	# exp 		: key Colon value exp | 'null';
	inc()
	key()
	if @tab[@i] != ":"
		abort("Błąd w definicji obiektu - brak :" + "#{show_errors}")
	else
		inc()
	end
	value()
end

def obj
	# object 	: LB exp RB ;
	if @tab[@i] == '{' 
		exp()
	else
		abort("Blad przy {" + "#{show_errors}") 	
	end	
	 	
	if @tab[@i] != '}' and @tab[@i] != nil
		abort("Blad przy }" + "#{show_errors}")
	end	
end

obj() 