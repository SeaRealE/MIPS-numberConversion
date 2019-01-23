# MIPS-numberConversion
MIPS assembly programming

## "요구 기능"
프로그램을 실행하면 사용자의 입력을 받기를 기다린다.
사용자는 정수 혹은 실수를 십진수 형태로 입력한다.

    예1) Enter the number: 12345
    
    예2) Enter the number: -293.1234

사용자가 엔터를 치면 최종적으로는 화면에 입력된 수에 해당하는 이진수를 출력한다.
입력이 정수이면 integer word의 이진수를 출력하고 입력이 floating point이면 32-bit single precision 
floating point로 표현된 이진비트를 출력한다. 하지만 최종 결과 출력 이전에 각 단계별 중간 결과도 출력한다. 
단계에 대한 설명은 아래를 참고한다.

    예1) Enter the number: 12345
         Input string: 12345
         Integer number detected
         Half of the input number: 6172
         Binary number: 0000 0000 0000 0000 0011 0000 0011 1001
         Hexa number: 00 00 30 39

    예2) Enter the number: -293.1234
         Input string: -293.1234
         Floating point number detected
         Half of the input number: -146.5617
         Binary number: 1100 0011 1001 0010 1000 1111 1100 1100
         Hexa number: C3 92 8F CC

사용자 입력은 정수인 경우 word 크기 이내로 표현 가능한 숫자이며 FP인 경우 32 bit single precision 형태로
표현 가능한 숫자라고 가정한다. 출력시 이진코드는 반드시 4비트마다 스페이스를 출력하고 헥사코드는 두자리마다 
스페이스를 출력한다.


## "동작 환경"
첨부된 MIPS emulator를 사용한다. Jar 파일이므로 윈도우즈 환경에서 자바를 설치한후 실행한다.
성공적으로 MIPS emulator를 실행하면 다음과 같은 창이 뜬다.

![결과](/data/sample.png)

F3는 소스코드를 assemble하는 단축키이다.
F5는 실행하는 단축키이다. 실행결과가 하단의 창에 출력되므로 여기서 출력된 결과를 확인 할 수 있다.
웹에 수많은 tutorial 자료들이 있으므로 검색하면 쉽게 자료를 찾을 수가 있다.

몇 개를 적어보면:

https://courses.cs.vt.edu/cs2506/Fall2014/Notes/L04.MIPSAssemblyOverview.pdf
http://logos.cs.uic.edu/366/notes/mips%20quick%20tutorial.htm
http://www.tfinley.net/notes/cps104/mips.html
http://web.engr.oregonstate.edu/~walkiner/cs271-wi13/slides/05-AssemblyProgramming.pdf
http://web.engr.oregonstate.edu/~walkiner/cs271-wi13/slides/07-MoreAssemblyProgramming.pdf
http://web.engr.oregonstate.edu/~walkiner/cs271-wi13/code/Hello.asm
http://web.engr.oregonstate.edu/~walkiner/cs271-wi13/code/Decls.asm
http://web.engr.oregonstate.edu/~walkiner/cs271-wi13/code/Add3.asm
http://web.engr.oregonstate.edu/~walkiner/cs271-wi13/code/Parrot.asm
https://www.cs.ucsb.edu/~franklin/64/lectures/mipsassemblytutorial.pdf

특히, 첫번째 링크에서의 hello world 예제를 따라가 보면 쉽게 코딩을 시작할 수 있다.


## "구현 순서"

과제 수행의 편의를 위해 아래와 같이 단계별 순서대로 구현한다고 생각하고 진행할 것.
- 1단계: 사용자 입력을 받는 기능 - 사용자에게 입력을 요구하고 받은 후 string으로 저장한다. 입력을 받을 때에는 "read string" syscall을 사용한다. 사용자가 입력하는 값이 정수인지 FP인지 미리 알 수 없으므로 "read integer"나 "read float"는 사용할 수가 없다.

- 2단계: 사용자가 입력한 데이터가 정수인지 FP인지 인식

- 3단계: 입력된 수 변환 기능 - 사용자가 입력한 수는 text로 저장되므로 이를 해석하여 word정수 혹은 FP형태의 수로 변환한다. 사용자가 123를 입력한 경우 이는 단순히 character ASCII code 배열 '1', '2'와 '3'이므로 이를 하나씩 읽으면서 하나의 register에서 정수값을 만들어야 한다. 1을 먼저 저장하고, 두번째 '2'를 볼때 1을 x10하고 2를 더하고, 마지막으로 세번째 '3'을 보면 이미 계산된 값에서 x10을 하고 3을 더한다. 실수일 경우 FP instruction을 사용하여 비슷한 작업을 한다.

- 4단계: 이진 비트 출력 기능

- 5단계: Hexa 코드로 출력

 각 단계의 동작을 확인하기 위해 단계별 결과를 위에서 이미 보여준 예시와 같이 출력한다. 단, 3단계의 결과는 입력된 값을 2로 나눈 후 출력한다.


## "첨부 파일"
["mars.jar 다운로드"](/data/mars.jar)


