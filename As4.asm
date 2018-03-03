// Written by Zachariah Albers
fmt1:		.string		"Pyramid %s origin = (%d, %d)\n"
fmt2:		.string		"\tBase width = %d Base length = %d\n"
fmt3:		.string		"\tHeight = %d\n"
fmt4:		.string		"\tVolume = %d\n\n"
fmt5:		.string		"Initial pyramid values:\n"
fmt6:		.string		"Changed pyramid values:\n"
first_str:	.string 	"first"
second_str: .string		"second"





.balign		4													// ensures instructions are properly aligned
.global		main												// executes main


// Variables and offsets

// Variable names
define(first_r, x20)
define(second_r, x21)
define(TRUE, w22)
define(FALSE, w23)

// Offsets for structures
point_x = 0
point_y = 4
point_size = 8

dimension_width = 0
dimension_length = 4
dimension_size = 8

pyramid_origin = 0
pyramid_base = 8
pyramid_height = 16
pyramid_volume = 20
pyramid_size = 24


// Size of variables in main
first_size = 24
second_size = 24

// Offsets for local variables in main
first_s = 16
second_s = 40

// Allocation and Deallocation for main
alloc = -(16 + first_size + second_size) & -16
dealloc = -alloc

main:
		stp		x29, x30, [sp, alloc]!								//saves FP and LR registers and allocates space for local variables
		mov		x29, sp												//update FP to current SP

		add 	first_r, x29, first_s								// Initialize offsets for first_r
		add 	second_r, x29, second_s								// Initialize offsets for second_r
		mov 	TRUE, 1												// Initialize TRUE to 1
		mov 	FALSE, 0											// Initialize FALSE to 0

		mov 	x8, first_r											// Set x8 to first_r
		bl 		newPyramid											// Branch and link to 'newPyramid' to initialize values of 'first'

		mov 	x8, second_r										// Set x8 to second_r
		bl 		newPyramid											// Branch and link to 'newPyramid' to initialize values of 'second'

		// Prints initial pyramid values
		adrp    x0, fmt5           		    						// puts the 'page' address into x0
		add     x0, x0, :lo12:fmt5									// Arg 1: puts the lower order 12 bits
		bl 		printf												// Print out string

		mov 	x0, first_r											// Arg 1: address of 'first'
		adrp 	x1, first_str										// Puts the 'page' address into x1
		add     x1, x1, :lo12:first_str								// Arg 2: puts the lower order 12 bits
		bl 		printPyramid										// Branch and link to 'printPyramid' with given arguments

		mov 	x0, second_r										// Arg 1: address of 'second'
		adrp 	x1, second_str										// Puts the 'page' address into x1
		add     x1, x1, :lo12:second_str							// Arg 2: puts the lower order 12 bits
		bl 		printPyramid										// Branch and link to 'printPyramid' with given arguments

		mov 	x0, first_r											// Arg 1: address of 'first'
		mov 	x1, second_r										// Arg 2: address of 'second'
		bl 		equalSize											// Branch and link to 'equal' with given arguments

		cmp 	w0, TRUE											// Compares w0 to TRUE
		b.ne 	print_final_values									// Branches to 'print_final_values' if not equal

		mov 	x8, first_r											// Set x8 to first_r
		mov 	w0, -5												// Arg 1: -5
		mov 	w1, 7												// Arg 2: 7
		bl 		move												// Branch and link to 'move' with given arguments

		mov 	x8, second_r										// Set x8 to second_r
		mov 	w0, 3												// Arg 1: 3
		bl 		scale												// Branch and link to 'scale' with given arguments

print_final_values:
		adrp    x0, fmt6 											// puts the 'page' address into x0
		add     x0, x0, :lo12:fmt6									// Arg 1: puts the lower order 12 bits
		bl 		printf												// Print out string

		mov 	x0, first_r											// Arg 1: address of 'first'
		adrp 	x1, first_str										// Puts the 'page' address into x1
		add     x1, x1, :lo12:first_str								// Arg 2: puts the lower order 12 bits
		bl 		printPyramid										// Branch and link to 'printPyramid' with given arguments

		mov 	x0, second_r										// Arg 1: address of 'second'
		adrp 	x1, second_str										// Puts the 'page' address into x1
		add     x1, x1, :lo12:second_str							// Arg 2: puts the lower order 12 bits
		bl 		printPyramid										// Branch and link to 'printPyramid' with given arguments

		ldp 	x29, x30, [sp], dealloc								// Restore states
		ret 														// Return 0 to OS




// Variable names used in newPyramid
define(p_r, x9)

// Allocation and Deallocation for newPyramid
alloc = -(16 + pyramid_size) & -16
dealloc = -alloc

// Offsets in newPyramid
p_s = 16

newPyramid:
		stp		x29, x30, [sp, alloc]!								// saves FP and LR registers and allocates space for local variables
		mov		x29, sp												// update FP to current SP

		add p_r, x29, p_s											// Calculate pyramid struct base address

		// Initialize local varialbe p_r
		str 	wzr, [p_r, pyramid_origin + point_x]				// p.origin.x = 0
		str 	wzr, [p_r, pyramid_origin + point_y]				// p.origin.y = 0
		mov 	w10, 2												//
		str 	w10, [p_r, pyramid_base + dimension_width]			// p.base.width = 2
		mov 	w11, 2												//
		str 	w11, [p_r, pyramid_base + dimension_length]			// p.base.length = 2
		mov 	w12, 3												//
		str 	w12, [p_r, pyramid_height]							// p.height = 3
		mul		w13, w10, w11										//
		mul		w13, w13, w12										//
		mov 	w14, 3												//
		sdiv 	w13, w13, w14										//
		str 	w13, [p_r, pyramid_volume]							// p.volume = (p.base.width * p.base.length * p.height) / 3

		// Returning pyramid structure to calling function
		ldr 	w10, [p_r, pyramid_origin + point_x]				//
		str 	w10, [x8, pyramid_origin + point_x]					// ret.origin.x = p.origin.x
		ldr 	w10, [p_r, pyramid_origin + point_y]				//
		str 	w10, [x8, pyramid_origin + point_y]					// ret.origin.y = p.origin.y
		ldr 	w10, [p_r, pyramid_base + dimension_width]			//
		str 	w10, [x8, pyramid_base + dimension_width]			// ret.base.width = p.base.width
		ldr 	w10, [p_r, pyramid_base + dimension_length]			//
		str 	w10, [x8, pyramid_base + dimension_length]			// ret.base.length = p.base.length
		ldr 	w10, [p_r, pyramid_height]							//
		str 	w10, [x8, pyramid_height]							// ret.height = p.height
		ldr 	w10, [p_r, pyramid_volume]							//
		str 	w10, [x8, pyramid_volume]							// ret.volume = p.volume

		ldp 	x29, x30, [sp], dealloc								// Restore states
		ret 														// Returns to calling function


define(printP_r, x19)


// Variable Names
define(printP_r, x19)

alloc = -(16 + 8) & -16
dealloc = -alloc

printPyramid:
        stp     x29, x30, [sp, alloc]!                              // saves FP and LR registers
        mov     x29, sp                                            // update FP to current SP


        str     printP_r, [x29, 16]                                 // Saves current x19 to stack
        mov     printP_r, x0                                 		// saves address of struct pyramid parameter to printP_r

		adrp    x0, fmt1           		   							// puts the 'page' address into x0
		add     x0, x0, :lo12:fmt1									// Arg 1: puts the lower order 12 bits
		// 		Arg 2: Already loaded into x1						// Arg 2: Already in lower order 12 bits
		ldr 	x2, [printP_r, pyramid_origin + point_x]			// Arg 3: p.origin.x
		ldr 	x3, [printP_r, pyramid_origin + point_y]			// Arg 4: p.origin.y
		bl 		printf												// Print out values in string

		adrp    x0, fmt2          		    						// puts the 'page' address into x0
		add     x0, x0, :lo12:fmt2									// Arg 1: puts the lower order 12 bits
		ldr 	x1, [printP_r, pyramid_base + dimension_width]		// Arg 2: p.base.width
		ldr 	x2, [printP_r, pyramid_base + dimension_length]		// Arg 3: p.base.length
		bl 		printf												// Print out values in string

		adrp    x0, fmt3         		    						// puts the 'page' address into x0
		add     x0, x0, :lo12:fmt3									// Arg 1: puts the lower order 12 bits
		ldr 	x1, [printP_r, pyramid_height]						// Arg 2: p.heigh
		bl 		printf												// Print out values in string

		adrp    x0, fmt4          		    						// puts the 'page' address into x0
		add     x0, x0, :lo12:fmt4									// Arg 1: puts the lower order 12 bits
		ldr 	x1, [printP_r, pyramid_volume]						// Arg 2: p.volume
		bl 		printf												// Print out values in string

		ldr 	printP_r, [x29, 16]
		ldp 	x29, x30, [sp], dealloc									// Restore states
		ret 														// Returns to calling function




// Size of variables in equalSize
result_size = 4

// Allocation and Deallocation for equalSize
alloc = -(16 + result_size) & -16
dealloc = -alloc

// Offsets in equalSize
result_s = 16

equalSize:
		stp		x29, x30, [sp, alloc]!								// allocates space for local variables
		mov		x29, sp												//update FP to current SP

		str 	FALSE, [x29, result_s]								// Initializing result to FALSE

		ldr 	w9, [x0, pyramid_base + dimension_width]			// w9 = p1.base.width
		ldr 	w10, [x1, pyramid_base + dimension_width]			// w10 = p2.base.width
		cmp 	w9, w10												// Compares w9 and w10
		b.ne	return_result										// Jumps to statement if not equal

		ldr 	w9, [x0, pyramid_base + dimension_length]			// w9 = p1.base.length
		ldr 	w10, [x1, pyramid_base + dimension_length]			// w10 = p2.base.length
		cmp 	w9, w10												// Compares w9 and w10
		b.ne	return_result										// Jumps to statement if not equal

		ldr 	w9, [x0, pyramid_height]							// w9 = p1.height
		ldr 	w10, [x1, pyramid_height]							// w10 = p2.height
		cmp 	w9, w10												// Compares w9 and w10
		b.ne	return_result										// Jumps to statement if not equal

		str 	TRUE, [x29, result_s]								// Sets result to TRUE

return_result:
		ldr 	w0, [x29, result_s]									// Loads result into w0

		ldp 	x29, x30, [sp], dealloc								// Restore states
		ret 														// Returns to calling function




move:
		stp		x29, x30, [sp, -16]!								// Saves FP and LR registers
		mov		x29, sp												// Update FP to current SP

		ldr 	w9, [x8, pyramid_origin + point_x]					// w9 = p->origin.x
		add 	w9, w9, w0											// adds argument w0 to w9
		str 	w9, [x8, pyramid_origin + point_x]					// stores new value to p->origin.x

		ldr 	w9, [x8, pyramid_origin + point_y]					// w9 = p->origin.y
		add 	w9, w9, w1											// adds argument w0 to w9
		str 	w9, [x8, pyramid_origin + point_y]					// stores new value to p->origin.y

		ldp 	x29, x30, [sp], 16									// Restore states
		ret 														// Returns to calling function




scale:
		stp		x29, x30, [sp, -16]!								// Saves FP and LR registers
		mov		x29, sp												// Update FP to current SP

		ldr 	w9, [x8, pyramid_base + dimension_width]			// w9 = p->origin.width
		mul 	w9, w9, w0											// multiplies w9 by argument w0
		str 	w9, [x8, pyramid_base + dimension_width]			// stores new value to p->origin.width

		ldr 	w10, [x8, pyramid_base + dimension_length]			// w10 = p->base.length
		mul 	w10, w10, w0										// multiplies w10 by argument w0
		str 	w10, [x8, pyramid_base + dimension_length]			// stores new value to p->origin.length

		ldr 	w11, [x8, pyramid_height]							// w11 = p->height
		mul 	w11, w11, w0										// multiplies w11 by argument w0
		str 	w11, [x8, pyramid_height]							// stores new value to p->height

		mul 	w12, w9, w10										//
		mul 	w12, w12, w11										//
		mov 	w13, 3												//
		sdiv 	w12, w12, w13										// w12 = (p->base.width * p->base.length * p->height) / 3
		str 	w12, [x8, pyramid_volume]							// stores new value to p-> volume

		ldp 	x29, x30, [sp], 16									// Restore states
		ret 														// Returns to calling function
