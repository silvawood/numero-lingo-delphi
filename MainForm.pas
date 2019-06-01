unit MainForm;

interface

uses
  Windows, SysUtils, Classes, Forms, Math, Gauges, Controls, StdCtrls, Buttons,
  registry, Dialogs, ComCtrls, ExtCtrls, Spin, Graphics, {HH, }Messages, ShellApi;

type
  TForm1 = class(TForm)
    btnStart: TButton;
    Label5: TLabel;
    Label6: TLabel;
    lblScore: TLabel;
    lblTopScore: TLabel;
    Timer1: TTimer;
    Label1: TLabel;
    btnHelp: TButton;
    btnExit: TButton;
    Gauge: TProgressBar;
    grpTestType: TGroupBox;
    grpQuestion: TGroupBox;
    lblNumberString1: TStaticText;
    grpAnswer: TGroupBox;
    lblArabicNumber: TStaticText;
    lblOperator: TLabel;
    lblNumberString2: TStaticText;
    btnStop: TButton;
    Label7: TLabel;
    lstLanguage: TComboBox;
    Label3: TLabel;
    lstDifficulty: TComboBox;
    Label2: TLabel;
    spnDuration: TSpinEdit;
    Label4: TLabel;
    btnNext: TButton;
    lblWrong: TLabel;
    lblCorrect: TImage;
    lblCorrection: TLabel;
    lblCorrectAnswer: TLabel;
    btnHint: TSpeedButton;
    lstTestType: TComboBox;
    lblLink: TLabel;
    procedure btnStartClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure showQuestion;
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure Timer1Timer(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure btnHelpClick(Sender: TObject);
    procedure btnExitClick(Sender: TObject);
    procedure lstDifficultyChange(Sender: TObject);
    procedure lstLanguageChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure checkTimer;
    procedure btnStopClick(Sender: TObject);
    procedure spnDurationChange(Sender: TObject);
    procedure btnNextClick(Sender: TObject);
    procedure choiceLabelClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure btnHintClick(Sender: TObject);
    procedure lstTestTypeChange(Sender: TObject);
    procedure lblLinkClick(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  score,topScore,previousNumber1,previousNumber2,questionNo,answerNo,currentPoint:Integer;
  phrase,answer,regKey:String;
  multipleChoice:Boolean;
  choiceLabel: array[0..3] of TLabel;
  language,testType:Cardinal;
  helpWindow: hwnd;

Const
    words: array[0..5,1..29] of String =
    (('one','two','three','four','five','six','seven','eight','nine','ten','eleven',
    'twelve','thirteen','fourteen','fifteen','sixteen','seventeen','eighteen','nineteen',
    'twenty','thirty','forty','fifty','sixty','seventy','eighty','ninety',
    'hundred','thousand'),
    ('un','deux','trois','quatre','cinq','six','sept','huit','neuf','dix','onze',
    'douze','treize','quatorze','quinze','seize','dix-sept','dix-huit','dix-neuf',
    'vingt','trente','quarante','cinquante','soixante','soixante','quatre-vingt','quatre-vingt',
    'cent','mille'),
    ('ein','zwei','drei','vier','fünf','sechs','sieben','acht','neun','zehn','elf',
    'zwölf','dreizehn','vierzehn','fünfzehn','sechzehn','siebzehn','achtzehn','neunzehn',
    'zwanzig','dreißig','vierzig','fünfzig','sechzig','siebzig','achtzig','neunzig',
    'hundert','tausend'),
    ('uno','due','tre','quattro','cinque','sei','sette','otto','nove','dieci','undici',
    'dodici','tredici','quattordici','quindici','sedici','diciassette','diciotto','diciannove',
    'vent','trent','quarant','cinquant','sessant','settant','ottant','novant',
    'cento','mil'),
    ('um','dois','três','quatro','cinco','seis','sete','oito','nove','dez','onze',
    'doze','treze','catorze','quinze','dezasseis','dezassete','dezoito','dezanove',
    'vinte','trinta','quarenta','cinquenta','sessenta','setenta','oitenta','noventa',
    'cento','mil'),
    ('uno','dos','tres','cuatro','cinco','seis','siete','ocho','nueve','diez','once',
    'doce','trece','catorce','quince','dieciséis','diecisiete','dieciocho','diecinueve',
    'veint','treinta','cuarenta','cincuenta','sesenta','setenta','ochenta','noventa',
    'cien','mil'));

    english: Byte=0;
    french: Byte=1;
    german: Byte=2;
    italian: Byte=3;
    portuguese: Byte=4;
    spanish: Byte=5;

    function decimalToWords(number:Integer):String;

implementation

{$R *.DFM}

procedure TForm1.btnStartClick(Sender: TObject);
begin
If score>topScore then
   begin
   topScore:=score;
   lblTopScore.Caption:=IntToStr(topScore);
   end;
score:=0;
lblScore.Caption:='0';
questionNo:=0;
lblArabicNumber.Caption:='';
btnNext.Enabled:=False;
btnStart.Enabled:=false;
btnStop.Enabled:=true;
Gauge.Position:=Gauge.Max;
Timer1.Enabled:=True;
showQuestion;
end;

procedure TForm1.choiceLabelClick(Sender: TObject);
var
  Key:Char;
begin
Key:=TLabel(Sender).Caption[1];
FormKeyPress(Sender,Key);
end;

procedure TForm1.showQuestion;
var
  number1, number2, randomBase, i, j, numericAnswer, answerBase, temp:Integer;
  choices:array[0..3] of Integer;
  S:String;
begin
inc(questionNo);
grpQuestion.Caption:=' Question '+IntToStr(questionNo)+' ';
randomBase:=Round(IntPower(10,lstDifficulty.ItemIndex));
lblCorrectAnswer.Visible:=false;
lblWrong.Visible:=false;
lblCorrect.Visible:=false;
lblCorrection.Visible:=false;
Repeat
   number1:=Random(9*randomBase)+randomBase;
Until (number1<>previousNumber1);
previousNumber1:=number1;
if testType>2 then
  begin //second number needed
  Repeat
    number2:=Random(9*randomBase)+randomBase;
  Until (number2<>previousNumber2) and (number2<>number1);
  //get random operator and calculate result
  with lblOperator do
    begin
    if Random(2)<1 then
      begin
      Caption:='+';
      Left:=193;
      Top:=51;
      numericAnswer:=number1+number2;
      end
    else
      begin
      Caption:='-';
      Left:=195;
      Top:=48;
      if number1<number2 then
        begin
        temp:=number1;
        number1:=number2;
        number2:=temp;
        end;
      numericAnswer:=number1-number2;
      end;
    end;
  lblNumberString2.Caption:=decimalToWords(number2);
  end
else
  numericAnswer:=number1;
if testType>1 then //question is in words
  lblNumberString1.Caption:=decimalToWords(number1)
else
  lblNumberString1.Caption:=IntToStr(number1);
if not multipleChoice then //answer is in digits, not multiple choice
  begin
  currentPoint:=1; //amount of answer entered so far
  answer:=IntToStr(numericAnswer);
  end
else
  begin
  for i:=0 to 3 do choices[i]:=0;
  answerNo:=Trunc(Random(4));
  answer:=Chr(answerNo+97); //a,b,c,d
  // show multiple choices
  if randomBase=1 then randomBase:=10;
  answerBase:=randomBase*(numericAnswer div randomBase);
  for i:=0 to 3 do
    begin
    S:=chr(i+97)+') ';
    if i=answerNo then
      S:=S+decimalToWords(numericAnswer)
    else
      begin
      Repeat
        choices[i]:=1+Random(randomBase)+answerBase;
        j:=0;
        while j<i do
          begin
          if choices[i]=choices[j] then Break; //choice already used
          inc(j);
          end;
      Until (j=i) and (choices[i]<>numericAnswer);
      S:=S+decimalToWords(choices[i]);
      end;
    choiceLabel[i].Caption:=S;
    choiceLabel[i].Font.Color:=clBlack;
    end;
  end;
end;

function decimalToWords(number:Integer):String;
begin
phrase:='';
If number>999 then
   begin
   If (number>1999) or (language=english) then
      phrase:=words[language,number div 1000];//no. of thousands
   if (language<>german) and (language<>italian) then
      phrase:=phrase+' '+words[language,29]+' '// add word for 'thousand'
   else
      begin
      phrase:=phrase+words[language,29];
      if (language=italian) then
         if (number>1999) then phrase:=phrase+'a' else phrase:=phrase+'le';
      end;
   number:=number Mod 1000;
   if (number<100) and (number>0) then
      begin
   		if (language=english) then
   			phrase:=phrase+'and '
   		else if (language=portuguese) then
      	phrase:=phrase+'e ';
      end;
   end;
If number>99 then
   begin
   If (language=spanish) then
      begin
      Case (number div 100) of
           5: phrase:=phrase+'quinientos';
           7: phrase:=phrase+'setecientos';
           9: phrase:=phrase+'novecientos';
      else
           if (number>199) then phrase:=phrase+words[spanish,number div 100];
           phrase:=phrase+words[spanish,28];
           if (number>100) then phrase:=phrase+'to';
           if (number>199) then phrase:=phrase+'s';
      end;
      end
   else if (language=portuguese) then
   		begin
      Case (number div 100) of
           1: if number>100 then phrase:=phrase+'cento' else phrase:=phrase+'cem';
           2: phrase:=phrase+'duzentos';
           3: phrase:=phrase+'trezentos';
           5: phrase:=phrase+'quinhentos';
      else
           phrase:=phrase+words[portuguese,number div 100]+'centos';
           end;
      end
   else
      begin
      if (number>199) or (language=english) or ((language=german) and (phrase>'')) then
         begin
         phrase:=phrase+words[language,number div 100];//no. of hundreds
         if (language<>german) and (language<>italian) then phrase:=phrase+' ';
         end;
      phrase:=phrase+words[language,28];//word for 'hundreds'
      end;
   If (number mod 100 > 0) then
      begin
      if (language=english) then
      	phrase:=phrase+' and'
      else if (language=portuguese) then
      	phrase:=phrase+' e';
      end
   else if (language=french) and (number>199) then
      phrase:=phrase+'s';//add 's' to 'cent' if number precedes but no number follows
   number:=number Mod 100;
   if (language<>german) and (language<>italian) then phrase:=phrase+' ';
   end;
If number>19 then
   begin
   if (language=german) then
      begin
      if (number mod 10>0) then phrase:=phrase+words[german,number mod 10]+'und';
      phrase:=phrase+words[german,number div 10 + 18];
      number:=0;
      end
   else
      begin
      phrase:=phrase+words[language,number div 10 + 18];
      If (language=french) then
         begin
         if (number mod 10 = 1) and (number<80) then
            phrase:=phrase+' et '
         else if (number mod 10 > 0) or (number=90) or (number=70) then
            phrase:=phrase+'-';
         if (number<60) then
           number:=number mod 10
         else if (number<80) then
           dec(number,60)
         else
           begin
           if (number=80) then phrase:=phrase+'s';
           dec(number,80);
           end;
         end
      else if (language=spanish) then
         begin
         if (number=20) then
            phrase:=phrase+'e'
         else if (number mod 10)>0 then
            begin
            if (number>29) then
               phrase:=phrase+' y '
            else if (number=22) then
               begin
               phrase:=phrase+'idós';
               number:=0;
               end
            else if (number=23) then
               begin
               phrase:=phrase+'itrés';
               number:=0;
               end
            else
               phrase:=phrase+'i';
            end;
         number:=number mod 10;
         end
      else if (language=italian) then
         begin
         if (number>29) then
            begin
            number:=number mod 10;
            if (number<>1) and (number<>8) then phrase:=phrase+'a';
            end
         else
            begin
            number:=number mod 10;
            if (number<>1) and (number<>8) then phrase:=phrase+'i';
            end;
         end
      else if (language=portuguese) then
         begin
         number:=number mod 10;
         if number>0 then phrase:=phrase+' e ';
         end
      else
         begin
         number:=number mod 10;
         phrase:=phrase+' ';
         end;
      end;
   end;
if (number>0) then
   begin
   if (language=italian) and (number=3) and (phrase>'') then
      phrase:=phrase+'trè'
   else
      begin
      phrase:=phrase+words[language,number];
      if (number=1) and (language=german) then phrase:=phrase+'s';
      end;
   end;
Result:=phrase;
end;

procedure TForm1.FormCreate(Sender: TObject);
var
  defaults,i:Cardinal;
begin
regKey:='Software\Silvawood\'+Application.Title;
lstLanguage.ItemIndex:=0;
With TRegistry.Create do
  begin
	try
		RootKey:=HKEY_CURRENT_USER;
		if OpenKey(regKey,false) then
			begin
  		if ValueExists('Defaults') then
      	begin
    		defaults:=ReadInteger('Defaults');
    		lstLanguage.ItemIndex:=defaults and 7;
    		lstDifficulty.ItemIndex:=(defaults shr 3) and 3;
        testType:=(defaults shr 5) and 3;
        lstTestType.ItemIndex:=testType;
        btnHint.Down:=((defaults and 128) <> 0);
        Application.ShowHint:=btnHint.Down;
        spnDuration.Value:=(defaults shr 8) and 63;
        end;
      end;
	except
  	end;
	Free;
  end;
language:=lstLanguage.ItemIndex;
lblArabicNumber.Caption:='';
topScore:=0;
for i:=0 to 3 do
  begin
  choiceLabel[i]:=TLabel.Create(grpAnswer);
  with choiceLabel[i] do
    begin
    Left:=40;
    Top:=24*(i+1);
    Parent:=grpAnswer;
    OnClick:=choiceLabelClick;
    end;
  end;
Randomize;
end;

procedure TForm1.FormKeyPress(Sender: TObject; var Key: Char);
var
  correct: Boolean;
  answerOptionTop,markLeft:Integer;
begin
If (btnNext.Enabled) or (Gauge.Position=0) then Exit;
if not multipleChoice then
  begin
  if (Key<'0') or (Key>'9') then Exit;
  lblArabicNumber.Caption:=lblArabicNumber.Caption+Key;
  If Key=answer[currentPoint] then
    begin
    Inc(currentPoint);
    If currentPoint>Length(answer) then correct:=true else Exit;
    end
  else
    begin
    correct:=false;
    lblCorrectAnswer.Caption:=answer;
    lblCorrectAnswer.Visible:=true;
    end;
  end
else
  begin
  if Key<'a' then inc(Key,32);
  if (Key<'a') or (Key>'d') then Exit;
  correct:=(Key=answer);
  answerOptionTop:=(Ord(Key)-96)*24;
  markLeft:=choiceLabel[answerNo].Width+62;
  if correct then
    begin
    lblCorrect.Top:=answerOptionTop-4;
    lblCorrect.Left:=markLeft;
    choiceLabel[answerNo].Font.Color:=clBlue;
    end
  else
    begin
    lblWrong.Top:=answerOptionTop-14;
    with choiceLabel[Ord(Key)-97] do
      begin
      lblWrong.Left:=Width+62;
      Font.Color:=clRed;
      end;
    lblCorrection.Top:=answerNo*24 + 14;
    lblCorrection.Left:=markLeft;
    choiceLabel[answerNo].Font.Color:=clGreen;
    end;
  end;
If correct then
  begin
  Inc(score);
  lblScore.Caption:=IntToStr(score);
  end;
btnNext.Enabled:=True;
btnNext.SetFocus;
lblCorrection.Visible:=not correct;
lblCorrect.Visible:=correct;
lblWrong.Visible:=not correct;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
Gauge.StepIt;
checkTimer;
end;

procedure TForm1.checkTimer;
begin
If Gauge.Position=0 then
  begin
  Timer1.Enabled:=False;
  lblNumberString1.Caption:='Test Over';
  lblNumberString2.Caption:='';
  lblOperator.Caption:='';
  btnStop.Enabled:=false;
  btnStart.Enabled:=true;
  btnNext.Enabled:=false;
  end;
end;

procedure TForm1.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
If Key=112 then
	Application.HelpCommand(HELP_CONTENTS,0);
end;

procedure TForm1.btnHelpClick(Sender: TObject);
begin
helpWindow:=HtmlHelp(GetDesktopWindow, 'NumeroLingo.chm', HH_DISPLAY_TOPIC, 0);
end;

procedure TForm1.btnExitClick(Sender: TObject);
begin
Form1.Close;
end;

procedure TForm1.lstDifficultyChange(Sender: TObject);
begin
if Gauge.Position>0 then
 	begin
 	Gauge.Position:=0;
 	checkTimer;
 	end;
end;

procedure TForm1.lstLanguageChange(Sender: TObject);
begin
language:=lstLanguage.ItemIndex;
if Gauge.Position>0 then
   begin
   Gauge.Position:=0;
   checkTimer;
   end;
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
With TRegistry.Create do
	try
		RootKey:=HKEY_CURRENT_USER;
		if OpenKey(regKey,true) then
			begin
    	WriteInteger('Defaults',language or (Cardinal(lstDifficulty.ItemIndex) shl 3)
      or (testType shl 5) or (Ord(btnHint.Down) shl 7) or (Cardinal(spnDuration.Value) shl 8));
  		end;
	finally
		Free;
  end;
end;

procedure TForm1.btnStopClick(Sender: TObject);
begin
lblOperator.Caption:='';
Gauge.Position:=0;
btnNext.Enabled:=false;
checkTimer;
end;

procedure TForm1.spnDurationChange(Sender: TObject);
var
	newSpin,error: Integer;
begin
Val(spnDuration.Text, newSpin, error);
if (error=0) and (newSpin>=spnDuration.MinValue) and (newSpin<=spnDuration.MaxValue) then
  Gauge.Max:=60*newSpin;
end;

procedure TForm1.btnNextClick(Sender: TObject);
begin
lblArabicNumber.Caption:='';
btnNext.Enabled:=False;
If Gauge.Position>0 then showQuestion;
end;

procedure TForm1.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
if IsWindow(helpWindow) then SendMessage(helpWindow,wm_close,0,0);
end;

procedure TForm1.btnHintClick(Sender: TObject);
begin
Application.ShowHint:=btnHint.Down;
end;

procedure TForm1.lstTestTypeChange(Sender: TObject);
var
  i:Integer;
begin
btnStopClick(Sender);
testType:=lstTestType.ItemIndex;
if testType>2 then
  begin
  lblNumberString1.Top:=25;
  lblNumberString2.Caption:='';
  lblNumberString2.Visible:=true;
  end
else
  begin
  lblOperator.Caption:='';
  lblNumberString2.Visible:=false;
  lblNumberString1.Top:=50;
  end;
multipleChoice:=(testType=1) or (testType=3);
if multipleChoice then
  begin
  grpAnswer.Caption:=' Select the answer ';
  lblArabicNumber.Visible:=false;
  end
else
  begin
  grpAnswer.Caption:=' Type the answer ';
  lblArabicNumber.Visible:=true;
  lblWrong.Top:=33;
  lblCorrect.Top:=44;
  lblWrong.Left:=242;
  lblCorrect.Left:=242;
  lblCorrection.Left:=241;
  lblCorrection.Top:=72;
  end;
for i:=0 to 3 do choiceLabel[i].Visible:=not lblArabicNumber.Visible;
lblCorrection.Visible:=false;
lblCorrect.Visible:=false;
lblWrong.Visible:=false;
end;

procedure TForm1.lblLinkClick(Sender: TObject);
begin
ShellExecute(Application.Handle, PChar('open'), PChar('http://www.silvawood.co.uk/lingo/'), PChar(0), nil, SW_NORMAL);
end;

end.
