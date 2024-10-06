사내에서 백신 마이그레이션 툴을 개발하기 위해 쉘 스크립트를 사용했다.
  
당시 프로그램의 이식성을 높이기 위해 어떤 경로에 있어도 인식할 수 있도록 아래 명령어를 통해 상대 경로를 가져오도록 했다.
  
```shell
CURRENT_PATH=$(dirname "$(readlink -f "$0")")
```
  
또한, 다른 쉘 스크립트 파일을 가져오기 위해 source를 사용했다.
  
```shell
source ../../common.sh
```
  
하지만, 첫번째 명령어의 경우 현재 쉘 스크립트 위치에 맞는 상대 경로를 가져왔지만, 두번째의 경우 인식하지 못하는 문제가 발생했다.
  
```shell
../../common.sh: No such file or directory
```
  
오류가 발생한 원인은 무엇일까?
  
직접 실행할 때와 달리 쉘 스크립트 내부에서 다른 쉘 스크립트를 실행할 때는 경로에 주의해야 한다.
  
쉘 스크립트 내부에서 다른 쉘 스크립트를 사용하는 경우, **상대 경로의 기준은 내부 쉘 스크립트가 아니라 실행하는 쉘 스크립트를 기준으로 동작하기 때문이다.**
  
쉘에 대해 조금 더 자세히 알아보자.
  
## 쉘(Shell)
쉘은 유닉스/리눅스 환경에서 사용자와 시스템 운영체제 간의 대화가 가능하도록 중계 역할을 하는 하나의 프로그램이다.
  
사용자가 명령 창을 통해 입력한 명령이나 스크립트 파일 안의 명령들을 해석해서 운영체제가 명령을 수행할 수 있도록 하며, 그 결과를 사용자에게 알려준다.
  
## 쉘 환경과 상속
쉘은 현재 쉘에서 서브 쉘을 생성하는 경우, 현재 쉘의 환경을 서브 쉘로 복사해서 상속하게 된다.  

이 때 상속되는 항목은 **프로세스 권한, 작업 디렉토리, 파일 생성 마스크, 특별 변수, 오픈한 파일, 시그널** 등이 있다.  

### 작업 디렉토리
부모 쉘로부터 파생되는 서브 쉘은 **현재 쉘의 작업 디렉토리를 그대로 상속받게 된다.**  

만약, 부모 쉘이 cd 명령으로 작업 디렉토리를 변경한 후 자식 쉘을 생성한다면, **변경된 부모의 작업 디렉토리가 그대로 자식 쉘의 작업 디렉토리가 된다.**  

주의할 점은 자식 쉘에서 변경한 작업 디렉토리는 자식 쉘이 종료되어 제어권이 부모에게로 다시 돌아왔을 때, **자식 쉘의 작업 디렉토리는 부모 쉘에서는 유효하지 않고, 부모는 자식 쉘을 생성할 당시의 작업 디렉토리에서 다시 시작하게 된다.**

## 쉘 스크립트의 실행 방식
쉘 스크립트의 실행 방식에 따라 **작업 디렉토리가 달라지는 경우**가 존재한다.

### 현재 쉘 실행 방식
![image](https://github.com/user-attachments/assets/1cceb70d-902e-47ef-8154-2b284a175534)

https://rhrhth23.tistory.com/85#google_vignettesource   

`source` 명령어로 특정 스크립트 파일을 실행하는 경우, 현재 쉘에서 명령어를 실행한다.  

현재 쉘에서 실행되기 때문에, `cd` 명령어 등으로 작업 디렉토리를 변경하면 현재 쉘의 작업 디렉토리가 변경된다.

### 서브 쉘 실행 방식
![image](https://github.com/user-attachments/assets/02e1d986-191d-493b-b612-0845d3d06620)

https://rhrhth23.tistory.com/85#google_vignette  

실행 파일을 `./runfile.sh` 로 직접 실행하는 경우, 서브 쉘에서 명령어를 실행한다.  

서브 쉘에서 실행되는 경우, 작업 디렉토리를 변경하더라도 현재 쉘의 작업 디렉토리가 그대로 유지된다.  

## 현재 쉘과 서브 쉘 실습하기
실행 결과는 다음과 같다.
### source 방식으로 하위 쉘 스크립트 실행 결과 (현재 쉘)
```shell
Hello, I am a Current Shell.
Current directory is /Users/hee/Desktop/shell-practice/current
Hello, I am a Sub Shell.
Current directory is /Users/hee/Desktop/shell-practice/change
```
### 직접 실행 방식으로 하위 쉘 스크립트 실행 결과 (서브 쉘)
```shell
Hello, I am a Current Shell.
Current2 directory is /Users/hee/Desktop/shell-practice/current
Hello, I am a Sub Shell.
Current2 directory is /Users/hee/Desktop/shell-practice/current
```

## 쉘 스크립트에서 상대 경로 사용하기
절대 경로를 사용하면 대부분의 오류는 해결되지만, 디렉토리의 이름이 바뀔 경우 문제가 생길 수 있으며, 이식성이 떨어진다.  

따라서, 이러한 문제를 해결하기 위해 쉘 스크립트가 자신의 디렉토리로 먼저 이동하는 `cd` 명령어를 사용할 수 있다. 

```shell
cd $(dirname $0)
```

* `$0` 은 현재 실행중인 스크립트 파일의 이름이나 경로를 가리킨다.
* `dirname` 명령어는 주어진 경로에서 파일 이름을 제외한 디렉토리 경로를 추출한다.

```shell
echo $(dirname /home/ubuntu/text.txt)

# 실행 결과
/home/ubuntu
```
하지만 해당 방법을 사용할 경우, **부모 쉘의 작업 디렉토리를 바꿀 수 있으니 유의해야한다.**  

또는, 아래 명령어를 사용해 현재 쉘 스크립트 파일의 위치를 절대 경로로 얻은 후 작업하는 방법도 있다.  
```shell
CURRENT_PATH=$(dirname "$(readlink -f "$0")")
```

* `readlink` 명령어는 심볼릭 링크의 실제 파일 혹은 파일의 절대 경로를 반환한다.

```shell
echo $(readlink -f /home/ubuntu/text.txt)

# 실행 결과
/home/ubuntu/text.txt
```

## 참고 자료
* https://blog.naver.com/PostView.nhn?isHttpsRedirect=true&blogId=big5347&logNo=220100371362  
* https://chanchan-father.tistory.com/846  
* https://rhrhth23.tistory.com/85
  
