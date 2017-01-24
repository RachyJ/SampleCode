<!DOCTYPE html>
<html>
<head>
    <title>Online OCR | Dynamic Web TWAIN SDK | Dynamsoft</title>
    <meta http-equiv="description" content="The sample demonstrates how to scan documents or import local images in browsers with Dynamic Web TWAIN, and then perform OCR at the client side." />
    <link href="Style/style.css" type="text/css" rel="stylesheet" />
    <script type="text/javascript" language="javascript" src="Resources/dynamsoft.webtwain.config.js"></script>  
	<script type="text/javascript" language="javascript" src="Resources/dynamsoft.webtwain.initiate.js"></script>  	
    <script type="text/javascript" language="javascript" src="Resources/addon/dynamsoft.webtwain.addon.ocrpro.js"> </script>
</head>

<body>
    <form id="form1" runat="server">
<div id="main">
 <div id="divDownloadSDK">
        <div id="divCaption">
            <div id="divCaptionLeft">
                <div class="floatLeft">
                    <img id="dbrLogo" src="Images/icon-DWT.png" alt="DBR Logo">   
                </div>
                <div class="floatLeft">
                    <div>
                        <a target="_blank" class="bluelink fontSize14" href="http://www.dynamsoft.com">Dynamsoft</a><span> / </span>
                        <a target="_blank" class="bluelink fontSize14" href="http://www.dynamsoft.com/Products/WebTWAIN_Overview.aspx">Dynamic Web TWAIN</a><span> / </span>
                        <a target="_blank" class="bluelink fontSize14" href="http://www.dynamsoft.com/Downloads/WebTWAIN-Sample-Download.aspx">code gallery</a><span> / </span>
                    </div>
                    <div class="displayBlock mt10">
                        <span id="desc1">Scan Documents and Client-side OCR</span>
                    </div>
                </div>
            </div>

            <div id="divCaptionRight">
                <a target="_blank" href="http://www.dynamsoft.com/Downloads/WebTWAIN_Download.aspx" class="largeBtnOrg">Download SDK</a>
            </div>
        </div>
        <div id="divSampleDesc" class="cl">
            <span class="blackGrayFont16">The sample demonstrates how to scan documents or import local images in browsers with Dynamic Web TWAIN, and then perform OCR at the client side.</span>
        </div>
    </div>
    <div class="minHeight40"></div>
     <div id="divOCR">
    <div id="divLeft" class="gray-border-right">
        <!-- dwtcontrolContainer is the default div id for Dynamic Web TWAIN control.
             If you need to rename the id, you should also change the id in the dynamsoft.webtwain.config.js accordingly. -->
        <div id="dwtcontrolContainer"></div>                         
    </div>  
    <div id="divRight">
     <input type="button" value="Scan" onclick="AcquireImage();" class="btnScan btnCommon" />
        <input type="button" value="Open a local image" onclick="LoadImage();" class="btnLoad btnCommon" />
        <div class="mt15">
            <label class="lblOCR">Language:</label>
            <select size="1" id="ddlLanguages" class="selectOCR"></select>
        </div>
        <div>
            <label class="lblOCR">Recognition Mode:</label>
            <select size="1" id="ddlOCRRecognitionModule" class="selectOCR"></select>
        </div>
       <div>
            <label class="lblOCR">Output Format:</label>
            <select size="1" id="ddlOCROutputFormat" class="selectOCR" onchange="SetIfUseRedaction();"></select>
        </div>
        <div id="divVersion" style="display:none">
            <div>
                <label class="lblOCR">PDF Version:</label>
                <select size="1" id="ddlPDFVersion"  class="selectOCR"></select>
            </div>
            <div>
                <label class="lblOCR">PDF/A Version:</label>
                <select size="1" id="ddlPDFAVersion"  class="selectOCR"></select>
            </div>
        </div>
        <div id= "divIfUseRedaction" style="display:none";>
            <label class="lblOCR"></label>
            <label class="blackGrayFont14"><input type="checkbox" id="chkUseRedaction" onchange="SetRedaction();" class="chkOCR"/>Search Text and Redact</label>
        </div>
        <div id= "divRedaction" style="display:none">
            <div>
                <label class="lblOCR">Find Text:</label>
                <input type="text" id= "txtFindText" value="" class="txtOCR" />
            </div>
            <div>
                <label class="lblOCR">Match Mode:</label>
                <select size="1" id="ddlFindTextFlags" class="selectOCR"></select>
            </div>
            <div>
                <label class="lblOCR">Find Text Action:</label>
                <select size="1" id="ddlFindTextAction" class="selectOCR"></select>
            </div>
        </div>
        <div>
            <label class="lblOCR"></label>
            <input type="button" value="OCR" onclick="DoOCRInner();" class="btnOCR" />
        </div>
        <div> <textarea id="ocrResult" rows="10" cols="50" name="S1" style="margin:30px"> </textarea> </div>
        <div style="display:none";>
            <input type="file" id="fileInput"/>
        </div>
    </div>
</div>  
</div>

    <script type="text/javascript">
        Dynamsoft.WebTwainEnv.RegisterEvent('OnWebTwainReady', Dynamsoft_OnReady); // Register OnWebTwainReady event. This event fires as soon as Dynamic Web TWAIN is initialized and ready to be used


        var DWObject;
        var _iLeft, _iTop, _iRight, _iBottom;

        var OCRFindTextFlags = [
                { desc: "whole word", val: EnumDWT_OCRFindTextFlags.OCRFT_WHOLEWORD },
                { desc: "match case", val: EnumDWT_OCRFindTextFlags.OCRFT_MATCHCASE },
                { desc: "fuzzy match", val: EnumDWT_OCRFindTextFlags.OCRFT_FUZZYMATCH }
        ];


        var OCRFindTextAction = [
                { desc: "highlight", val: EnumDWT_OCRFindTextAction.OCRFT_HIGHLIGHT },
                { desc: "strikeout", val: EnumDWT_OCRFindTextAction.OCRFT_STRIKEOUT },
                { desc: "mark for redact", val: EnumDWT_OCRFindTextAction.OCRFT_MARKFORREDACT }
        ];


        var OCRLanguages = [
                { desc: "English", val: "eng" },
                { desc: "Arabic", val: "arabic" },
                { desc: "Italian", val: "italian" }
        ];   
                
        var OCRRecognitionModule = [
                { desc: "auto", val: EnumDWT_OCRProRecognitionModule.OCRPM_AUTO },
                { desc: "most accurate", val: EnumDWT_OCRProRecognitionModule.OCRPM_MOSTACCURATE },
                { desc: "balanced", val: EnumDWT_OCRProRecognitionModule.OCRPM_BALANCED },
                { desc: "fastest", val: EnumDWT_OCRProRecognitionModule.OCRPM_FASTEST }
        ];   
             
        var OCROutputFormat = [
                { desc: "TXT", val: EnumDWT_OCRProOutputFormat.OCRPFT_TXTS },
                { desc: "CSV", val: EnumDWT_OCRProOutputFormat.OCRPFT_TXTCSV },
                { desc: "Text Formatted", val: EnumDWT_OCRProOutputFormat.OCRPFT_TXTF },
                { desc: "XML", val: EnumDWT_OCRProOutputFormat.OCRPFT_XML },
                { desc: "PDF", val: EnumDWT_OCRProOutputFormat.OCRPFT_IOTPDF },
                { desc: "PDF with MRC compression", val: EnumDWT_OCRProOutputFormat.OCRPFT_IOTPDF_MRC }
        ];

        var OCRPDFVersion = [
                { desc: "", val: ""},
                { desc: "1.0", val: EnumDWT_OCRProPDFVersion.OCRPPDFV_0 },
                { desc: "1.1", val: EnumDWT_OCRProPDFVersion.OCRPPDFV_1 },
                { desc: "1.2", val: EnumDWT_OCRProPDFVersion.OCRPPDFV_2 },
                { desc: "1.3", val: EnumDWT_OCRProPDFVersion.OCRPPDFV_3 },           
                { desc: "1.4", val: EnumDWT_OCRProPDFVersion.OCRPPDFV_4 },
                { desc: "1.5", val: EnumDWT_OCRProPDFVersion.OCRPPDFV_5 },
                { desc: "1.6", val: EnumDWT_OCRProPDFVersion.OCRPPDFV_6 },
                { desc: "1.7", val: EnumDWT_OCRProPDFVersion.OCRPPDFV_7 }

        ];

        var OCRPDFAVersion = [
                { desc: "", val: "" },
                { desc: "pdf/a-1a", val: EnumDWT_OCRProPDFAVersion.OCRPPDFAV_1A },
                { desc: "pdf/a-1b", val: EnumDWT_OCRProPDFAVersion.OCRPPDFAV_1B },
                { desc: "pdf/a-2a", val: EnumDWT_OCRProPDFAVersion.OCRPPDFAV_2A },
                { desc: "pdf/a-2b", val: EnumDWT_OCRProPDFAVersion.OCRPPDFAV_2B },
                { desc: "pdf/a-2u", val: EnumDWT_OCRProPDFAVersion.OCRPPDFAV_2U },
                { desc: "pdf/a-3a", val: EnumDWT_OCRProPDFAVersion.OCRPPDFAV_3A },
                { desc: "pdf/a-3b", val: EnumDWT_OCRProPDFAVersion.OCRPPDFAV_3B },
                { desc: "pdf/a-3u", val: EnumDWT_OCRProPDFAVersion.OCRPPDFAV_3U }

        ];

        function Dynamsoft_OnReady() {
            DWObject = Dynamsoft.WebTwainEnv.GetWebTwain('dwtcontrolContainer'); // Get the Dynamic Web TWAIN object that is embeded in the div with id 'dwtcontrolContainer'
            if (DWObject) {
                DWObject.RegisterEvent("OnImageAreaSelected", Dynamsoft_OnImageAreaSelected);
                DWObject.RegisterEvent("OnImageAreaDeSelected", Dynamsoft_OnImageAreaDeselected);
                
                _iLeft = 0;
                _iTop = 0;
                _iRight = 0;
                _iBottom = 0;
                
                for (var i = 0; i < OCRFindTextFlags.length; i++)
                    document.getElementById("ddlFindTextFlags").options.add(new Option(OCRFindTextFlags[i].desc, i));
                for (var i = 0; i < OCRFindTextAction.length; i++)
                    document.getElementById("ddlFindTextAction").options.add(new Option(OCRFindTextAction[i].desc, i));                  
                for (var i = 0; i < OCRLanguages.length; i++)
                    document.getElementById("ddlLanguages").options.add(new Option(OCRLanguages[i].desc, i));
                for (var i = 0; i < OCROutputFormat.length; i++)
                    document.getElementById("ddlOCROutputFormat").options.add(new Option(OCROutputFormat[i].desc, i));
                for (var i = 0; i < OCRRecognitionModule.length; i++)
                    document.getElementById("ddlOCRRecognitionModule").options.add(new Option(OCRRecognitionModule[i].desc, i));
                for (var i = 0; i < OCRPDFVersion.length; i++)
                    document.getElementById("ddlPDFVersion").options.add(new Option(OCRPDFVersion[i].desc, i));
                for (var i = 0; i < OCRPDFAVersion.length; i++)
                    document.getElementById("ddlPDFAVersion").options.add(new Option(OCRPDFAVersion[i].desc, i));

                document.getElementById("ddlPDFVersion").selectedIndex = 6;

                DWObject.RegisterEvent("OnTopImageInTheViewChanged", Dynamsoft_OnTopImageInTheViewChanged);
                DWObject.RegisterEvent("OnGetFilePath", Dynamsoft_OnGetFilePath);
            }
        }

        function Dynamsoft_OnImageAreaSelected(index, left, top, right, bottom) {
            _iLeft = left;
            _iTop = top;
            _iRight = right;
            _iBottom = bottom;
        }

        function Dynamsoft_OnImageAreaDeselected(index) {
            _iLeft = 0;
            _iTop = 0;
            _iRight = 0;
            _iBottom = 0;
        }

        function Dynamsoft_OnTopImageInTheViewChanged(index) {
            DWObject.CurrentImageIndexInBuffer = index;
        }

        function AcquireImage() {
            if (DWObject) {
                var bSelected = DWObject.SelectSource();
                if (bSelected) {

                    var OnAcquireImageSuccess, OnAcquireImageFailure;
                    OnAcquireImageSuccess = OnAcquireImageFailure = function() {
                        DWObject.CloseSource();
                    };

                    DWObject.OpenSource();
                    DWObject.IfDisableSourceAfterAcquire = true;  //Scanner source will be disabled/closed automatically after the scan.
                    DWObject.AcquireImage(OnAcquireImageSuccess, OnAcquireImageFailure);
                }
            }
        }

        function LoadImage() {

            var OnSuccess = function() {
            };

            var OnFailure = function(errorCode, errorString) {
                alert(errorString);
            };

            if (DWObject) {
                DWObject.IfShowFileDialog = true;  //Open the system's file dialog to load image
                DWObject.LoadImageEx("", EnumDWT_ImageType.IT_ALL, OnSuccess, OnFailure);    //Load images in all supported formats (.bmp, .jpg, .tif, .png, .pdf). OnSuccess or OnFailure will be called after the operation
            }
        }

        function SetIfUseRedaction() {
            var selectValue = OCROutputFormat[document.getElementById("ddlOCROutputFormat").selectedIndex].val;
            if (selectValue == EnumDWT_OCRProOutputFormat.OCRPFT_IOTPDF ||
                selectValue == EnumDWT_OCRProOutputFormat.OCRPFT_IOTPDF_MRC) {
                document.getElementById("divVersion").style.display = "";
                document.getElementById("divIfUseRedaction").style.display = "";
            }
            else if (selectValue == EnumDWT_OCRProOutputFormat.OCRPFT_TXTF) {
                document.getElementById("divVersion").style.display = "none";
                document.getElementById("divIfUseRedaction").style.display = "";
            }
            else {
                document.getElementById("divVersion").style.display = "none";
                document.getElementById("divIfUseRedaction").style.display = "none";
                document.getElementById("divRedaction").style.display = "none";
                document.getElementById("chkUseRedaction").checked = false;
            }
        }

        function SetRedaction() {
             if (document.getElementById("chkUseRedaction").checked) {
                 document.getElementById("divRedaction").style.display = "";
            }
            else {
                document.getElementById("divRedaction").style.display = "none";
                document.getElementById("chkUseRedaction").checked = false;
            }
        }

        function GetErrorInfo(errorcode, errorstring, result) { //This is the function called when OCR fails
            alert(errorstring);
            var strErrorDetail = "";
            var aryErrorDetailList = result.GetErrorDetailList();
            for (var i = 0; i < aryErrorDetailList.length; i++) {
                if (i > 0)
                    strErrorDetail += ";";
                strErrorDetail += aryErrorDetailList[i].GetMessage();
            }
            alert(strErrorDetail);
        }
        
        function GetRectOCRProInfo(sImageIndex, aryZone, result) { 
            return GetOCRProInfoInner(result);
        }


        function GetOCRProInfo(sImageIndex, result) {        
            return GetOCRProInfoInner(result);
        }

        function GetOCRProInfoInner(result) {  
            if (result == null)
                return null;
                
            var pageCount = result.GetPageCount();
            if (pageCount == 0) {
                alert("OCR result is Null.");
                return;
            } else {

                var bRet = "";
                for (var i = 0; i < pageCount; i++) {
                    var page = result.GetPageContent(i);
                    var letterCount = page.GetLettersCount();
                    for (var n = 0; n < letterCount; n++) {
                        var letter = page.GetLetterContent(n);
                        bRet += letter.GetText();

                    }
                }
                console.log(bRet);  //Get OCR result.
                document.getElementById("ocrResult").value = bRet;
            }

            //if(savePath.length > 1)
            //    result.Save(savePath);
            document.getElementById("ocrResult").Value = result;
        }

       // var savePath;
        //function Dynamsoft_OnGetFilePath(bSave, count, index, path, name) {
        //    if (path.length > 0 || name.length > 0)
        //        savePath = path + "\\" + name; 
        //    if (bSave == true && index != -1032) //if cancel, do not ocr
        //        DoOCRInner();
        //}

        //function DoOCR() {                
        //    if (DWObject) {
        //        if (DWObject.HowManyImagesInBuffer == 0) {
        //            alert("Please scan or load an image first.");
        //            return;
        //        }

        //        var saveTye = "";
        //        var fileType = "";
        //        switch (OCROutputFormat[document.getElementById("ddlOCROutputFormat").selectedIndex].val) {
        //            case EnumDWT_OCRProOutputFormat.OCRPFT_TXTS:
        //                fileType = ".txt";
        //                saveTye = "Plain Text(*.txt)";
        //                break;
        //            case EnumDWT_OCRProOutputFormat.OCRPFT_TXTCSV:
        //                fileType = ".csv";
        //                saveTye = "CSV(*.csv)";
        //                break;  
        //            case EnumDWT_OCRProOutputFormat.OCRPFT_TXTF:
        //                fileType = ".rtf";
        //                saveTye = "Rich Text Format(*.rtf)";
        //                break; 
        //            case EnumDWT_OCRProOutputFormat.OCRPFT_XML:
        //                fileType = ".xml";
        //                saveTye = "XML Document(*.xml)";
        //                break; 
        //            case EnumDWT_OCRProOutputFormat.OCRPFT_IOTPDF:
        //            case EnumDWT_OCRProOutputFormat.OCRPFT_IOTPDF_MRC:
        //                fileType = ".pdf";
        //                saveTye = "PDF(*.pdf)";
        //                break;     
        //        }
        //        var fileName = "result" + fileType;

        //      //  DWObject.ShowFileDialog(true, saveTye, 0, "", fileName, true, false, 0); 

        //      }
        //}


        function DoOCRInner() {
            if (DWObject) {
                if (DWObject.HowManyImagesInBuffer == 0) {
                    alert("Please scan or load an image first.");
                    return;
                }

                //Call DWObject.Addon.OCRPro.Download(url) to download ocr module to local.

            var OnSuccess = function() {
                    var settings = Dynamsoft.WebTwain.Addon.OCRPro.NewSettings();
                    settings.RecognitionModule = OCRRecognitionModule[document.getElementById("ddlOCRRecognitionModule").selectedIndex].val;
                    settings.Languages = OCRLanguages[document.getElementById("ddlLanguages").selectedIndex].val;
                   // settings.OutputFormat = OCROutputFormat[document.getElementById("ddlOCROutputFormat").selectedIndex].val;
                    //var selectValue = OCROutputFormat[document.getElementById("ddlOCROutputFormat").selectedIndex].val;
                    //if (selectValue == EnumDWT_OCRProOutputFormat.OCRPFT_IOTPDF ||
                    //    selectValue == EnumDWT_OCRProOutputFormat.OCRPFT_IOTPDF_MRC) {
                    //    settings.PDFVersion = OCRPDFVersion[document.getElementById("ddlPDFVersion").selectedIndex].val;
                    //    settings.PDFAVersion = OCRPDFAVersion[document.getElementById("ddlPDFAVersion").selectedIndex].val;
                    //}
                    //if (document.getElementById("chkUseRedaction").checked) {
                    //    settings.Redaction.FindText = document.getElementById("txtFindText").value;
                    //    settings.Redaction.FindTextFlags = OCRFindTextFlags[document.getElementById("ddlFindTextFlags").selectedIndex].val;
                    //    settings.Redaction.FindTextAction = OCRFindTextAction[document.getElementById("ddlFindTextAction").selectedIndex].val;
                    //}
                    DWObject.Addon.OCRPro.Settings = settings;

                    //Get ocr result.
                    if (_iLeft != 0 || _iTop != 0 || _iRight != 0 || _iBottom != 0) {

                        var zoneArray = [];
                        var zone = Dynamsoft.WebTwain.Addon.OCRPro.NewOCRZone(_iLeft, _iTop, _iRight, _iBottom);
                        zoneArray.push(zone);
                        DWObject.Addon.OCRPro.RecognizeRect(DWObject.CurrentImageIndexInBuffer, zoneArray, GetRectOCRProInfo, GetErrorInfo);
                    }
                    else
                        DWObject.Addon.OCRPro.Recognize(DWObject.CurrentImageIndexInBuffer, GetOCRProInfo, GetErrorInfo);
                }

            };

            var OnFailure = function(errorCode, errorString) {
                alert("onfailure!");

            };

            var CurrentPathName = unescape(location.pathname);
            CurrentPath = CurrentPathName.substring(0, CurrentPathName.lastIndexOf("/") + 1);
            DWObject.Addon.OCRPro.Download(CurrentPath + "Resources/addon/OCRPro.zip", OnSuccess, OnFailure);
        }


       
    </script>
    </form>
</body>
</html>
