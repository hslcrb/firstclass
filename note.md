grid-template-columns
- 명시적 열(Track)의 크기를 정의
- 동시에 라인(Line)의 이름도 정의
- fr(fraction, 공간비율)단위 사용가능
- repeat()함수 사용

grod-templates-rows
- 명시적 행(Track)의 크기를 정의
- 동시에 라인(Line)의 이름도 정의
- fr(fraction, 공간비율)단위 사용가능
- repeat()함수 사용

@media (max-width: 1280px)


auto-fit에서 아이템이 넓어지는 것은 최대 크기가 1fr처럼 유연할 때
minmax(200px, 250px)처럼 최대 너비를 고정하면 무한정 넓어지진 않음
아이템이 생성된 열을 모두 채우고 있다면 사실상 같은 결과임(fill과 fit)