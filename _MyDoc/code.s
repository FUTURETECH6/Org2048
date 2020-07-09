# a0: 
# a1: 
# s1: the info of current key pressed
# s2: 
# s3: const 0xF0: 断码
init:
    # 假设我前面预留512条指令的位置，那么我的数据起始地址就是4*512.
    addi $s6, $zero, 0x3F0        # s6:存放16个格子数据的起始地址.
    addi $t0, $zero, 0x1;
    sw $t0, 0($s6);
    sw $t0, 4($s6);
    addi $s5, $zero, 0x0        # 存放伪随机数列的起始地址
    addi $s4, $zero, 0x04;        # 比较常量4
    # addi $a3, $zero, 0xFFFFD000;
    lui $a3, 0xD000;    # 存放按键信息的地址
    # slo $a3;
    # slo $a3;
    # slo $a3;
    # slo $a3;
    # slo $a3;
    addi $t9, $zero, 0x444;  # 存放当前操作的伪随机数
    add $s7, $zero, $zero;
    add $s2, $zero, $zero;
    addi $s3, $zero, 0xF0;
begin:
    lw $s1, 0($a3);
    beq $s1, $s3, begin;
    beq $s1, $s2, begin;  # 0/0xF0 need to wait
    add $s2, $zero, $s1;        
    add $s7, $zero, $zero;        # s7存储这一次按键中是否生成新的方块。
    j tryright;
    
loop:
    # a0---偏移量 （记得要是4的倍数） a1用来判断哪4个砖块不进行判断操作
    # a0 = -4. 判断左移。特点：mod 4 = 0. index & 0011 ==0000.
    # a0 = 4. 判断右移。特点：mod 4 = 3. index & 0011 ==0011.
    # a0 = -16. 判断上移。特点：div 4 = 0. index & 1100 ==0000.
    # a0 = 16. 判断下移。特点：div 4 = 3. index & 1100 ==1100.
    addi $t1, $zero, 1;        # t1 = i = 1,2,3
    loop1:
        beq $t1, $s4, exitloop;    #  i=4，退出循环
            add $t2, $zero, $zero;    # t2 = j =0
            loop2:
                beq $t2, $s4,loop2end    # t2 = 4,退出循环
                    addi $t3, $zero, 0x0;         # t3 = k = 0..3
                    loop3:
                            beq $t3, $s4, loop3end;
                            add $t4, $zero, $t2;
                            add $t4, $t4, $t4;
                            add $t4, $t4, $t4;
                            add $t4, $t4, $t3;    # 先把当前方块的index算出来
            
                            addi $t5, $zero, -4;
                            addi $t6, $zero, -16;
                            if1:
                                bne $a0, $t5,if2;
                                addi $t8, $zero, 3;
                                and $t7, $t4, $t8;
                                beq $t7, $zero, jbreak;
                                beq $zero, $zero, continue;
                            if2:
                                bne $a0, $s4,if3;
                                addi $t8, $zero,3;
                                and $t7, $t4, $t8;
                                beq $t7, $t8, jbreak;
                                beq $zero, $zero, continue;
                            if3:
                                bne $a0, $t6,if4;
                                addi $t8, $zero, 0xc;
                                and $t8, $t8, $t4;
                                beq $t8,$zero, jbreak;
                                beq $zero, $zero, continue; 
                            if4:                
                                addi $t8, $zero,0xc;
                                and $t7, $t8, $t4;
                                beq $t7, $t8, jbreak;
                                beq $zero, $zero, continue;
                    continue:

                            add $t4, $t4, $t4;
                            add $t4, $t4, $t4;
                            add $t4, $t4, $s6;
                            add $t8, $t4, $a0;    # 加偏移量
                            lw $t5, 0($t4);
                            lw $t6, 0($t8);
                    
                            addi $t3, $t3, 1;
                            bne $t6, $zero,  loop3;
                            sw $zero, 0($t4);
                            sw $t5, 0($t8);
                            addi $s7, $s7, 1;
                            beq $zero, $zero, loop3;
                    jbreak:
                            addi $t3, $t3, 1;
                            beq $zero, $zero, loop3;

                    loop3end:
                addi $t2, $t2, 1;
                beq $zero, $zero, loop2;
            loop2end:    
        addi $t1, $t1, 1;
        beq $zero, $zero, loop1;
    exitloop:
        jr $ra;


tryright:
    addi $t1, $zero, 0x0023;
    beq $s1, $t1, right;
    bne $s1, $t1, tryleft;

right:
    addi $a0, $zero, 4;
    jal loop;

        add $t1, $zero, $zero;            # t1 = 0..3
        right2loop1:
            beq $t1, $s4, right2loop1exit;    
                addi $t2, $zero, 3;    # t2 = 3..1
                right2loop2:
                    beq $t2,$zero,right2loop2end;
                    add $t4, $zero, $t1;
                    add $t4, $t4, $t4;
                    add $t4, $t4, $t4;
                    add $t4, $t4, $t2;
                    addi $t4, $t4, -1;    # t2实际上从2..0
                    add $t4, $t4, $t4;
                    add $t4, $t4, $t4;
                    add $t4, $s6, $t4;
                    lw $t5, 0($t4);
                    lw $t6, 4($t4);
                    addi $t2, $t2, -1;
                    bne $t5, $t6, right2loop2;
                    beq $t5, $zero, right2loop2;
                    sw $zero, 0($t4);
                    addi $t6, $t6,1;
                    sw $t6, 4($t4);
                    addi $s7, $s7,1;
                    beq $zero, $zero, right2loop2; 
                right2loop2end:
            addi $t1, $t1, 1;
            beq $zero, $zero, right2loop1;            
        right2loop1exit:

    jal loop;
    beq $zero, $zero, done;        

tryleft:
    addi $t1, $zero, 0x001C;
    beq $s1, $t1, left;
    bne $s1, $t1, tryup;

left:
    addi $a0, $zero, -4;
    jal loop;

        add $t1, $zero, $zero;            # t1 = 0..3
        left2loop1:
            beq $t1, $s4, left2loop1exit;    
                addi $t2, $zero, 1;    # t2 = 1..3
                left2loop2:
                    beq $t2,$s4,left2loop2end;
                    add $t4, $zero, $t1;
                    add $t4, $t4, $t4;
                    add $t4, $t4, $t4;
                    add $t4, $t4, $t2;
                    add $t4, $t4, $t4;
                    add $t4, $t4, $t4;
                    add $t4, $s6, $t4;
                    lw $t5, 0($t4);
                    lw $t6, -4($t4);
                    addi $t2, $t2, 1;
                    bne $t5, $t6, left2loop2;
                    beq $t5, $zero, left2loop2;
                    sw $zero, 0($t4);
                    addi $t6, $t6,1;
                    sw $t6, -4($t4);
                    addi $s7, $s7,1;
                    beq $zero, $zero, left2loop2; 
                left2loop2end:
            addi $t1, $t1, 1;
            beq $zero, $zero, left2loop1;            
        left2loop1exit:

    jal loop;
    beq $zero, $zero, done;        


tryup:
    addi $t1, $zero, 0x001D;
    beq $s1, $t1, up;
    bne $s1, $t1, trydown;

up:
    addi $a0, $zero, -16;
    jal loop;

        add $t1, $zero, $zero;            # t1 = 0..3
        up2loop1:
            beq $t1, $s4, up2loop1exit;    
                addi $t2, $zero, 1;    # t2 = 1..3
                up2loop2:
                    beq $t2,$s4,up2loop2end;
                    add $t4, $zero, $t2;
                    add $t4, $t4, $t4;
                    add $t4, $t4, $t4;
                    add $t4, $t4, $t1;
                    add $t4, $t4, $t4;
                    add $t4, $t4, $t4;
                    add $t4, $s6, $t4;
                    lw $t5, 0($t4);
                    lw $t6, -16($t4);
                    addi $t2, $t2, 1;
                    bne $t5, $t6, up2loop2;
                    beq $t5, $zero, up2loop2;
                    sw $zero, 0($t4);
                    addi $t6, $t6,1;
                    sw $t6, -16($t4);
                    addi $s7, $s7,1;
                    beq $zero, $zero, up2loop2; 
                up2loop2end:
            addi $t1, $t1, 1;
            beq $zero, $zero, up2loop1;            
        up2loop1exit:

    jal loop;
    beq $zero, $zero, done;        


trydown: 
    addi $t1, $zero, 0x001B;
    beq $s1, $t1, down;
    bne $s1, $t1, done;

down:
    addi $a0, $zero, 16;
    jal loop;

        add $t1, $zero, $zero;            # t1 = 0..3
        down2loop1:
            beq $t1, $s4, down2loop1exit;    
                addi $t2, $zero, 3;    # t2 = 3..1
                down2loop2:
                    beq $t2,$zero,down2loop2end;
                    add $t4, $zero, $t2;
                    addi $t4, $t4, -1;    # 实际上t2从2..0 
                    add $t4, $t4, $t4;
                    add $t4, $t4, $t4;
                    add $t4, $t4, $t1;
                    add $t4, $t4, $t4;
                    add $t4, $t4, $t4;
                    add $t4, $s6, $t4;
                    lw $t5, 0($t4);
                    lw $t6, 16($t4);
                    addi $t2, $t2, -1;
                    bne $t5, $t6, down2loop2;
                    beq $t5, $zero, down2loop2;
                    sw $zero, 0($t4);
                    addi $t6, $t6,1;
                    sw $t6, 16($t4);
                    addi $s7, $s7,1;
                    beq $zero, $zero, down2loop2; 
                down2loop2end:
            addi $t1, $t1, 1;
            beq $zero, $zero, down2loop1;            
        down2loop1exit:

    jal loop;
    beq $zero, $zero, done;        

done:
    # 根据s7决定是否生成新的砖块
    # beq $zero, $zero, begin;
    beq $s7, $zero, begin;
    # t3,t4,t5,t6,t7
    
    lw $t3, 0($s5);                # 0x840处存放一共存储了多少个伪随机数列.
    addi $t4, $t9, 0;
    add $t5, $zero, $t3;
    sll $t5, $t5, 2;
    addi $t5, $t5, 0x444;            # 结束地址
    tryloop:    
            lw $t6, 0($t4); # t6 = 1,2,3,...16应该放在第几个空block中
            add $t7, $zero, $zero;        # t7 计数器                # 循环放在第几个空块
            add $t0, $zero, $s6;        # 从第一个开始循环
            thenloop:
            beq $t6, $t7, success;         # 完成了循环    
            then2:
                beq $t0, $s5 , thenend; 
                lw $t1, 0($t0);            # 取出他的值
                addi $t0, $t0,4;
                beq $t1, $zero, then2end;        # 如果是0， 循环结束
                beq $zero, $zero, then2;
            then2end:
                addi $t7, $t7, 1;
                beq $zero, $zero, thenloop;
         
        thenend:
            addi $t4, $t4, 4;
            bne $t4, $t9, goon;
            addi $t6, $zero, 0xFFFF;
            sw $t6, 0($s6);
            beq $zero, $zero, dead;
            goon:
            bne $t4, $t5, tryloop;
            addi $t4, $zero, 0x444;
            beq $zero, $zero, tryloop;
            
        success:
            addi $t1, $zero, 1;
            sw $t1, -4($t0);
            addi $t9, $t9, 4;
            bne $t9, $t5, goon1;
            addi $t9, $zero, 0x444;
        goon1:
            beq $zero, $zero, begin;

dead:
    j dead;