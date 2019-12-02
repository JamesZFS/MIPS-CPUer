	.section .mdebug.abi32
	.previous
	.nan	legacy
	.module	fp=32
	.module	nooddspreg
	.abicalls
	.text
$Ltext0:
	.align	2
	.globl	_Z3divii
$LVL0 = .
$LFB0 = .
	.file 1 "fpn_math.cpp"
	.loc 1 3 35 view -0
	.cfi_startproc
	.set	nomips16
	.set	nomicromips
	.ent	_Z3divii
	.type	_Z3divii, @function
_Z3divii:
	.frame	$sp,0,$31		# vars= 0, regs= 0/0, args= 0, gp= 0
	.mask	0x00000000,0
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	.loc 1 4 5 view $LVU1
	.loc 1 5 1 is_stmt 0 view $LVU2
	move	$2,$0
	jr	$31
	nop

	.set	macro
	.set	reorder
	.end	_Z3divii
	.cfi_endproc
$LFE0:
	.size	_Z3divii, .-_Z3divii
	.align	2
	.globl	_Z4sqrti
$LVL1 = .
$LFB1 = .
	.loc 1 8 1 is_stmt 1 view -0
	.cfi_startproc
	.set	nomips16
	.set	nomicromips
	.ent	_Z4sqrti
	.type	_Z4sqrti, @function
_Z4sqrti:
	.frame	$sp,40,$31		# vars= 0, regs= 4/0, args= 16, gp= 8
	.mask	0x80070000,-4
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	.loc 1 8 1 is_stmt 0 view $LVU4
	addiu	$sp,$sp,-40
	.cfi_def_cfa_offset 40
	sw	$31,36($sp)
	sw	$18,32($sp)
	sw	$17,28($sp)
	sw	$16,24($sp)
	.cfi_offset 31, -4
	.cfi_offset 18, -8
	.cfi_offset 17, -12
	.cfi_offset 16, -16
	move	$18,$4
	.loc 1 9 5 is_stmt 1 view $LVU5
	.loc 1 9 22 is_stmt 0 view $LVU6
	sra	$16,$4,1
$LVL2 = .
	.loc 1 10 5 is_stmt 1 view $LVU7
$LBB2 = .
	.loc 1 10 23 is_stmt 0 view $LVU8
	move	$17,$0
$LVL3 = .
$L4:
	.loc 1 10 32 is_stmt 1 discriminator 3 view $LVU9
	slt	$2,$17,10
	beq	$2,$0,$L2
	nop

	.loc 1 11 9 discriminator 2 view $LVU10
	.loc 1 11 20 is_stmt 0 discriminator 2 view $LVU11
	move	$5,$16
	move	$4,$18
	.option	pic0
	jal	_Z3divii
	nop

	.option	pic2
$LVL4 = .
	.loc 1 11 11 discriminator 2 view $LVU12
	addu	$16,$2,$16
$LVL5 = .
	.loc 1 12 9 is_stmt 1 discriminator 2 view $LVU13
	.loc 1 12 11 is_stmt 0 discriminator 2 view $LVU14
	sra	$16,$16,1
$LVL6 = .
	.loc 1 10 5 is_stmt 1 discriminator 2 view $LVU15
	addiu	$17,$17,1
$LVL7 = .
	.loc 1 10 5 is_stmt 0 discriminator 2 view $LVU16
	.option	pic0
	b	$L4
	nop

	.option	pic2
$L2:
	.loc 1 10 5 discriminator 2 view $LVU17
$LBE2 = .
	.loc 1 15 1 view $LVU18
	move	$2,$16
	lw	$31,36($sp)
	lw	$18,32($sp)
$LVL8 = .
	.loc 1 15 1 view $LVU19
	lw	$17,28($sp)
$LVL9 = .
	.loc 1 15 1 view $LVU20
	lw	$16,24($sp)
$LVL10 = .
	.loc 1 15 1 view $LVU21
	addiu	$sp,$sp,40
	.cfi_restore 16
	.cfi_restore 17
	.cfi_restore 18
	.cfi_restore 31
	.cfi_def_cfa_offset 0
	jr	$31
	nop

	.set	macro
	.set	reorder
	.end	_Z4sqrti
	.cfi_endproc
$LFE1:
	.size	_Z4sqrti, .-_Z4sqrti
$Letext0:
	.section	.debug_info,"",@progbits
$Ldebug_info0:
	.4byte	0xdd
	.2byte	0x4
	.4byte	$Ldebug_abbrev0
	.byte	0x4
	.uleb128 0x1
	.4byte	$LASF0
	.byte	0x4
	.4byte	$LASF1
	.4byte	$LASF2
	.4byte	$Ltext0
	.4byte	$Letext0-$Ltext0
	.4byte	$Ldebug_line0
	.uleb128 0x2
	.4byte	$LASF3
	.byte	0x1
	.byte	0x1
	.byte	0xd
	.4byte	0x31
	.uleb128 0x3
	.byte	0x4
	.byte	0x5
	.ascii	"int\000"
	.uleb128 0x4
	.4byte	$LASF4
	.byte	0x1
	.byte	0x7
	.byte	0x9
	.4byte	$LASF5
	.4byte	0x25
	.4byte	$LFB1
	.4byte	$LFE1-$LFB1
	.uleb128 0x1
	.byte	0x9c
	.4byte	0xad
	.uleb128 0x5
	.ascii	"a\000"
	.byte	0x1
	.byte	0x7
	.byte	0x16
	.4byte	0x25
	.4byte	$LLST0
	.4byte	$LVUS0
	.uleb128 0x6
	.ascii	"x\000"
	.byte	0x1
	.byte	0x9
	.byte	0x16
	.4byte	0x25
	.4byte	$LLST1
	.4byte	$LVUS1
	.uleb128 0x7
	.4byte	$LBB2
	.4byte	$LBE2-$LBB2
	.uleb128 0x6
	.ascii	"i\000"
	.byte	0x1
	.byte	0xa
	.byte	0x17
	.4byte	0x31
	.4byte	$LLST2
	.4byte	$LVUS2
	.uleb128 0x8
	.4byte	$LVL4
	.4byte	0xad
	.uleb128 0x9
	.uleb128 0x1
	.byte	0x54
	.uleb128 0x2
	.byte	0x82
	.sleb128 0
	.uleb128 0x9
	.uleb128 0x1
	.byte	0x55
	.uleb128 0x2
	.byte	0x80
	.sleb128 0
	.byte	0
	.byte	0
	.byte	0
	.uleb128 0xa
	.ascii	"div\000"
	.byte	0x1
	.byte	0x3
	.byte	0x9
	.4byte	$LASF6
	.4byte	0x25
	.4byte	$LFB0
	.4byte	$LFE0-$LFB0
	.uleb128 0x1
	.byte	0x9c
	.uleb128 0xb
	.ascii	"a\000"
	.byte	0x1
	.byte	0x3
	.byte	0x15
	.4byte	0x25
	.uleb128 0x1
	.byte	0x54
	.uleb128 0xb
	.ascii	"b\000"
	.byte	0x1
	.byte	0x3
	.byte	0x20
	.4byte	0x25
	.uleb128 0x1
	.byte	0x55
	.byte	0
	.byte	0
	.section	.debug_abbrev,"",@progbits
$Ldebug_abbrev0:
	.uleb128 0x1
	.uleb128 0x11
	.byte	0x1
	.uleb128 0x25
	.uleb128 0xe
	.uleb128 0x13
	.uleb128 0xb
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x1b
	.uleb128 0xe
	.uleb128 0x11
	.uleb128 0x1
	.uleb128 0x12
	.uleb128 0x6
	.uleb128 0x10
	.uleb128 0x17
	.byte	0
	.byte	0
	.uleb128 0x2
	.uleb128 0x16
	.byte	0
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x39
	.uleb128 0xb
	.uleb128 0x49
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0x3
	.uleb128 0x24
	.byte	0
	.uleb128 0xb
	.uleb128 0xb
	.uleb128 0x3e
	.uleb128 0xb
	.uleb128 0x3
	.uleb128 0x8
	.byte	0
	.byte	0
	.uleb128 0x4
	.uleb128 0x2e
	.byte	0x1
	.uleb128 0x3f
	.uleb128 0x19
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x39
	.uleb128 0xb
	.uleb128 0x6e
	.uleb128 0xe
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x11
	.uleb128 0x1
	.uleb128 0x12
	.uleb128 0x6
	.uleb128 0x40
	.uleb128 0x18
	.uleb128 0x2117
	.uleb128 0x19
	.uleb128 0x1
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0x5
	.uleb128 0x5
	.byte	0
	.uleb128 0x3
	.uleb128 0x8
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x39
	.uleb128 0xb
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x2
	.uleb128 0x17
	.uleb128 0x2137
	.uleb128 0x17
	.byte	0
	.byte	0
	.uleb128 0x6
	.uleb128 0x34
	.byte	0
	.uleb128 0x3
	.uleb128 0x8
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x39
	.uleb128 0xb
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x2
	.uleb128 0x17
	.uleb128 0x2137
	.uleb128 0x17
	.byte	0
	.byte	0
	.uleb128 0x7
	.uleb128 0xb
	.byte	0x1
	.uleb128 0x11
	.uleb128 0x1
	.uleb128 0x12
	.uleb128 0x6
	.byte	0
	.byte	0
	.uleb128 0x8
	.uleb128 0x4109
	.byte	0x1
	.uleb128 0x11
	.uleb128 0x1
	.uleb128 0x31
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0x9
	.uleb128 0x410a
	.byte	0
	.uleb128 0x2
	.uleb128 0x18
	.uleb128 0x2111
	.uleb128 0x18
	.byte	0
	.byte	0
	.uleb128 0xa
	.uleb128 0x2e
	.byte	0x1
	.uleb128 0x3f
	.uleb128 0x19
	.uleb128 0x3
	.uleb128 0x8
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x39
	.uleb128 0xb
	.uleb128 0x6e
	.uleb128 0xe
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x11
	.uleb128 0x1
	.uleb128 0x12
	.uleb128 0x6
	.uleb128 0x40
	.uleb128 0x18
	.uleb128 0x2117
	.uleb128 0x19
	.byte	0
	.byte	0
	.uleb128 0xb
	.uleb128 0x5
	.byte	0
	.uleb128 0x3
	.uleb128 0x8
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x39
	.uleb128 0xb
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x2
	.uleb128 0x18
	.byte	0
	.byte	0
	.byte	0
	.section	.debug_loc,"",@progbits
$Ldebug_loc0:
$LVUS0:
	.uleb128 0
	.uleb128 $LVU9
	.uleb128 $LVU9
	.uleb128 $LVU19
	.uleb128 $LVU19
	.uleb128 0
$LLST0:
	.4byte	$LVL1-$Ltext0
	.4byte	$LVL3-$Ltext0
	.2byte	0x1
	.byte	0x54
	.4byte	$LVL3-$Ltext0
	.4byte	$LVL8-$Ltext0
	.2byte	0x1
	.byte	0x62
	.4byte	$LVL8-$Ltext0
	.4byte	$LFE1-$Ltext0
	.2byte	0x4
	.byte	0xf3
	.uleb128 0x1
	.byte	0x54
	.byte	0x9f
	.4byte	0
	.4byte	0
$LVUS1:
	.uleb128 $LVU7
	.uleb128 $LVU21
	.uleb128 $LVU21
	.uleb128 0
$LLST1:
	.4byte	$LVL2-$Ltext0
	.4byte	$LVL10-$Ltext0
	.2byte	0x1
	.byte	0x60
	.4byte	$LVL10-$Ltext0
	.4byte	$LFE1-$Ltext0
	.2byte	0x1
	.byte	0x52
	.4byte	0
	.4byte	0
$LVUS2:
	.uleb128 $LVU8
	.uleb128 $LVU9
	.uleb128 $LVU9
	.uleb128 $LVU20
$LLST2:
	.4byte	$LVL2-$Ltext0
	.4byte	$LVL3-$Ltext0
	.2byte	0x2
	.byte	0x30
	.byte	0x9f
	.4byte	$LVL3-$Ltext0
	.4byte	$LVL9-$Ltext0
	.2byte	0x1
	.byte	0x61
	.4byte	0
	.4byte	0
	.section	.debug_aranges,"",@progbits
	.4byte	0x1c
	.2byte	0x2
	.4byte	$Ldebug_info0
	.byte	0x4
	.byte	0
	.2byte	0
	.2byte	0
	.4byte	$Ltext0
	.4byte	$Letext0-$Ltext0
	.4byte	0
	.4byte	0
	.section	.debug_line,"",@progbits
$Ldebug_line0:
	.section	.debug_str,"MS",@progbits,1
$LASF0:
	.ascii	"GNU C++14 9.2.1 20190831 -G 0 -mel -mllsc -mno-shared -m"
	.ascii	"abi=32 -g -Og -fno-builtin\000"
$LASF2:
	.ascii	"/Users/james/Test/cod19grp16/demo\000"
$LASF4:
	.ascii	"sqrt\000"
$LASF6:
	.ascii	"_Z3divii\000"
$LASF3:
	.ascii	"fpn32_t\000"
$LASF1:
	.ascii	"fpn_math.cpp\000"
$LASF5:
	.ascii	"_Z4sqrti\000"
	.ident	"GCC: (GNU) 9.2.1 20190831"
