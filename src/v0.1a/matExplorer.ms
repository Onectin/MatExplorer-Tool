-- INFOS
-- MatlibExplorer
-- v0.1a
-- 23/05/2015
-- onectin@onectin.fr
--
-- Thumbnail dotnet generation script from "PolyTools3D"
-- http://forums.cgsociety.org/archive/index.php/t-1239911.html
--
-- Drag n drop to viewport script from "MarcoBrunetta"
-- http://forums.cgsociety.org/archive/index.php/t-685803.html
-- --------------------------
-- matlibExplorer.ms


-- INIT
if classof matLibExpUi == RolloutClass do destroydialog matLibExpUi

_prefDir = getdir #temp
_prefFile = _prefDir + "matExp_wimPos.ini"
_checkPrefFile = getFiles _prefFile

_rolloutStyle = #(#style_toolwindow,#style_border, #style_sysmenu ,#style_minimizebox, #style_titlebar)
_height = 658
_width = 240

-- UI
rollout matLibExpUi "Material Explorer" width:_width height:_height
(
	-- UI: VAR
	local _matLibDir = (getDir #matlib) + "\\"
	local _tempDir = (getDir #temp) + "\\"
	local _fileToLoad = ""
	local _currentList = #()
	local _dotnetList = #()
	local _matList = #()
	local _currentId = 0
	local _currentSize = 32
	local _offset = 0
	local _defBitmapPrev = bitmap 88 88 color:(color 51 51 51)
	local _currentObjMouse
	local _dragDrop = false

	-- UI: TOOLTIPS

	-- UI: DESCRIPTION
	groupBox 		_grpMatlib			"Source" 					pos:[8,8] 			width:224 	height:64
	editText 		_edtExplore			"" 							pos:[12,24] 		width:188 	height:16
	button 			_btnPath			"..." 						pos:[200,25] 		width:24 	height:15
	button 			_btnLoad			"Load" 						pos:[16,48] 		width:96 	height:16
	button 			_btnClear			"Clear" 					pos:[128,48] 		width:96 	height:16
	groupBox 		_grpMaterials		"Materials" 				pos:[8,78] 			width:224 	height:552
	editText 		_edtMatSearch		"" 							pos:[12,94] 		width:192 	height:16
	button 			_btnSize			"▼" 						pos:[208,94] 		width:16 	height:16
	dotNetControl 	_lbxMaterials 	"System.Windows.Forms.ListView" pos:[16,112] 		width:208 	height:398
	bitmap 			_bmpMatPreview		"Bitmap" 					pos:[24,480+48] 	width:88 	height:88
	groupBox 		_grpMatPreview		"Preview" 					pos:[16,464+48] 	width:208 	height:110
	checkbox 		_chkActivatePrev 	"" 							pos:[120,480+48] 	width:16 	height:16
	label 			_lblActivatePrev	"Activate" 					pos:[140,480+48] 	width:48 	height:16
	button 			_btnCalculatePrev	"Update" 					pos:[120,500+48] 	width:96 	height:24
	button 			_btnClose			"Close" 					pos:[8,634] 		width:224 	height:18

	function fnInitImgLists =
	(
		global _dNet_imgListTiny = dotNetObject "System.Windows.Forms.ImageList"
		_dNet_imgListTiny.ColorDepth = _dNet_imgListTiny.ColorDepth.Depth24Bit
		_dNet_imgListTiny.ImageSize = dotNetObject "System.Drawing.Size" 18 18
		global _dNet_imgListSmall = dotNetObject "System.Windows.Forms.ImageList"
		_dNet_imgListSmall.ColorDepth = _dNet_imgListSmall.ColorDepth.Depth24Bit
		_dNet_imgListSmall.ImageSize = dotNetObject "System.Drawing.Size" 32 32
		global _dNet_imgListLarge = dotNetObject "System.Windows.Forms.ImageList"
		_dNet_imgListLarge.ColorDepth = _dNet_imgListLarge.ColorDepth.Depth24Bit
		_dNet_imgListLarge.ImageSize = dotNetObject "System.Drawing.Size" 88 88
	)

	-- UI: FUNCTIONS
	function fnGetMouseObj =
	(
		local theRay=mapScreenToWorldRay mouse.pos
		local dist=undefined
		local theHit=undefined
		local _mouseObj=undefined
		
		for x in objects do
		(
			hitRay=intersectRay x theRay
			
			if hitRay!=undefined then
			(
				tempDist=distance hitRay.pos theRay.pos
				
				if dist==undefined or tempDist<dist then
				(
					dist=tempDist
					theHit=hitRay
					_mouseObj = X
				)
			)
		)
		_mouseObj
	)

	function fnGetMatPreview _matNameArray =
	(
		rollout _progressWin "Progress" width:336 height:48
		(
			progressBar 	prbProgress "" 													pos:[8,24] width:320 height:16
			label 			lblProgress "Calculating previews. It may take some time..." 	pos:[8,6] width:320 height:16
		)


		local _maxGlobal = (dotnetClass "Autodesk.Max.GlobalInterface").Instance
		local _sysPtr = dotnetClass "System.IntPtr"
		local _sceneMtls = _maxGlobal.CoreInterface.SceneMtls
		local _collectedMat = #()
		local _returnArray = #()

		for i = 0 to _sceneMtls.NumSubs-1 do 
		(
			for u in _matNameArray do
			(
				if _sceneMtls.Item[dotnetObject _sysPtr i].Name == u do
				(
					append _collectedMat _sceneMtls.Item[dotnetObject _sysPtr i]
				)
			)
		)

		-- Sort the array, to make items unique, twice: bug to fix !!!
		for y = 1 to 2 do
		(
			for i in _collectedMat do
			(
				_counter = 0
				for u in _collectedMat do
				(
					if i != u do
					(
						_counter = _counter + 1
						if i.name == u.name do deleteItem _collectedMat _counter
					)
				)
			)
		)


		function fnGenerateThumbnail _size _material =
		(
			if _size == 18 do (local _stamp = (dotnetclass "Autodesk.Max.PostageStampsize").Tiny)
			if _size == 32 do (local _stamp = (dotnetclass "Autodesk.Max.PostageStampsize").Small)
			if _size == 88 do (local _stamp = (dotnetclass "Autodesk.Max.PostageStampsize").Large)

			if _size == 88 then (_gamma = 0.5) else (_gamma = 1)


			local _tmpStamp = _material.CreatePStamp _stamp true
			local _tmpSBytes = _tmpStamp.Image
			local _sizeBmp = _tmpStamp.Width
			local _bitMap = bitmap _sizeBmp _sizeBmp gamma:_gamma
			local _step = _sizeBmp*3

			for i = 1 to _tmpSBytes.count by _step do
			(
				local _row = for u = i to (i+_step-1) by 3 collect [_tmpSBytes[u+2], _tmpSBytes[u+1], _tmpSBytes[u]]
				setpixels _bitMap [0, _sizeBmp-=1] _row
			)

			-- Convert max bitmap to dotnet bitmap
			setClipboardBitmap _bitMap
			local clipboardObj = dotNetClass "System.Windows.Forms.Clipboard"
			local imgObj = clipboardObj.GetImage()

			if _size == 18 do (_dNet_imgListTiny.images.add imgObj)
			if _size == 32 do (_dNet_imgListSmall.images.add imgObj)
			if _size == 88 do (_dNet_imgListLarge.images.add imgObj)

			_tmpStamp.Dispose()

			return _bitMap
		)

		if _maxGlobal != undefined do
		(
			if _chkActivatePrev.checked do
			(
				local _stepsPb = (100/_collectedMat.count+1)
				local _valuePb = 0
				createDialog _progressWin
				_progressWin.prbProgress.color = (color 28 149 177)
			)

			for _mat in _collectedMat do
			(
				if _chkActivatePrev.checked then
				(
					local _bmp18 = fnGenerateThumbnail 18 _mat
					local _bmp32 = fnGenerateThumbnail 32 _mat
					local _bmp88 = fnGenerateThumbnail 88 _mat

					_valuePb = _valuePb + _stepsPb
					_progressWin.prbProgress.value = (_valuePb as integer)
				)
				else
				(
					local _bmp18 = ""
					local _bmp32 = ""
					local _bmp88 = ""
				)
				
				append _returnArray #(_mat.Name, _mat.ClassName, _bmp18, _bmp32, _bmp88)
				append _currentList #(_mat.Name, _mat.ClassName, _bmp18, _bmp32, _bmp88)
				
				_mat.Dispose()
			)

			if _chkActivatePrev.checked do DestroyDialog _progressWin
		)
		dotNetImgList = #(_dNet_imgListTiny, _dNet_imgListSmall, _dNet_imgListLarge)
		_dotnetList = dotNetImgList
		return _returnArray --#(#(name, class, bitmap24, bitmap88), ...)		
	)

	function fnInitList =
	(
		_lbxMaterials.Clear()
		_lbxMaterials.View = (dotNetClass "System.Windows.Forms.View").Details
		_lbxMaterials.borderstyle = (dotnetclass "System.Windows.Forms.BorderStyle").fixedsingle
		_lbxMaterials.showitemtooltips = false
		_lbxMaterials.gridlines = false
		_lbxMaterials.checkboxes = false
		_lbxMaterials.labeledit = false
		_lbxMaterials.BackColor = (dotNetClass "System.Drawing.Color").fromARGB 121 121 121
		_lbxMaterials.ForeColor = (dotNetClass "System.Drawing.Color").fromARGB 230 230 230
		
		if _currentSize == 32 do
		(
			_lbxMaterials.Columns.add "Id" 36
			_lbxMaterials.Columns.add "Name" 90
			_lbxMaterials.Columns.add "Class" 64
		)
		
		if _currentSize == 18 do
		(
			_lbxMaterials.Columns.add "Id" 22
			_lbxMaterials.Columns.add "Name" 95
			_lbxMaterials.Columns.add "Class" 73
		)
	)

	function fnFillList =
	(
		if _currentList.count > 0 do
		(		
			if _chkActivatePrev.checked do
			(
				if _currentSize == 18 do _lbxMaterials.SmallImageList = _dotnetList[1] -- Small
				if _currentSize == 32 do _lbxMaterials.SmallImageList = _dotnetList[2] -- Tiny
			)
			
			for i = 1 to (_currentList.count) do
			(
				local _offsetList = i + _offset
				local _currentMaterial = _currentList[_offsetList]
				if _currentMaterial != undefined do
				(
					if _chkActivatePrev.checked then
					(
						ListViewOps.AddLvItem _lbxMaterials pTextItems:#((_offsetList as string),_currentMaterial[1], _currentMaterial[2]) pImgIndex:(_offsetList-1)
					)
					else
					(
						ListViewOps.AddLvItem _lbxMaterials pTextItems:#((_offsetList as string),_currentMaterial[1], _currentMaterial[2]) pImgIndex:9999
					)
				)
			)
		)
	)

	function fnAssignCurrentIdMat =
	(
		_currentSel = selection as array
		if _currentSel.count >= 1 and _currentId != 0 do
		(
			for i in _currentSel do i.material = _matList[_currentId]
		)
	)
	
	-- UI: INIT
	on matLibExpUi open do
	(
		fnInitImgLists()
		fnInitList()
		_chkActivatePrev.checked = true
		_bmpMatPreview.bitmap = _defBitmapPrev
	)

	on matLibExpUi moved _pos do
	(
	    setIniSetting _prefFile "Window_Position" "position" (_pos as string)
	)

	-- UI: BEHAVIOUR
	on _btnLoad pressed do
	(
		local _fileToLoad = _edtExplore.text
		if _fileToLoad != undefined and _fileToLoad != "" do
		(
			local _matNamesArray = #()
			local _fileType = getFilenameType _fileToLoad
			if _fileType == ".mat" do
			(
				loadMaterialLibrary _fileToLoad
				for i=1 to currentMaterialLibrary.count do
				(
					_tmpBox = box()
					_tmpBox.height = 0
					_tmpBox.width = 0
					_tmpBox.name = "#tmpObj_matScript_" + (i as string)
					_tmpBox.material = currentMaterialLibrary[i]
					_matName = currentMaterialLibrary[i].name
					append _matList _tmpBox.material
					append _matNamesArray _matName

					delete _tmpBox
				)
			)
			if _fileType == ".max" do
			(
				
				clearSelection()
				_mergeOp = mergeMAXFile _fileToLoad #select #autoRenameDups #promptMtlDups #neverReparent
				_newObjects = selection as array
				clearSelection()

				loadDefaultMatLib()

				for i = 1 to currentMaterialLibrary.count do (deleteItem currentMaterialLibrary 1)

				for i in _newObjects do
				(
					if i.material != undefined do
					(
						append currentMaterialLibrary i.material
					)
					delete i
				)
				for i=1 to currentMaterialLibrary.count do
				(
					_tmpBox = box()
					_tmpBox.height = 0
					_tmpBox.width = 0
					_tmpBox.name = "#tmpObj_matScript_" + (i as string)
					_tmpBox.material = currentMaterialLibrary[i]
					_matName = currentMaterialLibrary[i].name
					append _matList _tmpBox.material
					append _matNamesArray _matName
					delete _tmpBox
				)


			)
			if _fileType != ".max" and _fileType != ".mat" do
			(

			)

			fnGetMatPreview _matNamesArray
			--fnInitList()
			fnFillList()
			_offset = _offset + currentMaterialLibrary.count
		)
	)

	on _btnCalculatePrev pressed do
	(
		fnInitList()
		_currentList = #()
		_dotnetList = #()
		_currentId = 0
		_offset = 0
		_edtMatSearch.text= ""

		_matNamesArray = #()
		
		for i in _matList do
		(
			append _matNamesArray i.name
		)

		fnGetMatPreview _matNamesArray
		fnFillList()
		_bmpMatPreview.bitmap = _defBitmapPrev
	)

	on _btnClear pressed do 
	(
		_currentList = #()
		_dotnetList = #()
		_matList = #()
		_currentId = 0
		_offset = 0
		fnInitList()
		fnInitImgLists()
		_bmpMatPreview.bitmap = _defBitmapPrev
	)

	on _btnSize pressed do
	(
		if _currentSize == 18 then
		(
			_offset = 0
			_currentSize = 32
			_btnSize.text = "▼"
			fnInitList()
			fnFillList()
			_offset = _offset + currentMaterialLibrary.count
		)
		else
		(
			_offset = 0
			_currentSize = 18
			_btnSize.text = "▲"
			fnInitList()
			fnFillList()
			_offset = _offset + currentMaterialLibrary.count
		)
	)

	on _edtMatSearch changed _arg do
	(
		_searchStr = _edtMatSearch.text
		_count = _searchStr.count
		_matchingMat = #()
		_counter = 0
		for i in _currentList do
		(
			_counter = _counter + 1
			_matName = i[1]
			_subString = substring _matName 1 _count
			_newArr = i
			append _newArr _counter
			if _subString == _searchStr do append _matchingMat _newArr
		)
		--print _matchingMat
		if _matchingMat.count > 0 do
		(		
			fnInitList()
			if _chkActivatePrev.checked do
			(
				if _currentSize == 18 do _lbxMaterials.SmallImageList = _dotnetList[1] -- Small
				if _currentSize == 32 do _lbxMaterials.SmallImageList = _dotnetList[2] -- Tiny
			)
			
			for i = 1 to (_matchingMat.count) do
			(
				--local _offsetList = i + _offset
				local _currentMaterial = _matchingMat[i]
				if _currentMaterial != undefined do
				(
					if _chkActivatePrev.checked then
					(
						local _currentMat = _matchingMat[i]
						local _currentThumbId = _currentMat[6]
						ListViewOps.AddLvItem _lbxMaterials pTextItems:#((i as string),_currentMaterial[1], _currentMaterial[2]) pImgIndex:(_currentThumbId-1)
					)
					else
					(
						ListViewOps.AddLvItem _lbxMaterials pTextItems:#((i as string),_currentMaterial[1], _currentMaterial[2]) pImgIndex:9999
					)
				)
			)
		)
	)

	on _lbxMaterials mouseUp _arg do
	(
		_dragDrop = false
		_hit=(_lbxMaterials.HitTest (dotNetObject "System.Drawing.Point" _arg.x _arg.y))
		_itemsList = _hit.item

		if _itemsList != undefined and _chkActivatePrev.checked do
		(
			_id = (_hit.item.text as integer)
			_currentId = _id
			_currentMat = _currentList[_id]
			_bmpMatPreview.bitmap = _currentMat[5]
		)
	)

	on _lbxMaterials ItemDrag _arg do
	(
		_dragDrop = true
		_currentId = _arg.item.index+1
	)

	on _lbxMaterials lostFocus _arg do
	(
		_currentObjMouse = fnGetMouseObj()
		
		if _currentObjMouse != undefined and _dragDrop == true do
		(
			_currentObjMouse.material = _matList[_currentId]
		)

		_currentObjMouse = undefined
	)

	on _lbxMaterials DoubleClick _arg do
	(
		fnAssignCurrentIdMat()
	)

	on _btnPath pressed do
	(
		_fileToLoad = getOpenFileName caption:"Pick a source file" initialDir:_matLibDir types:"Matlib (*.mat)||Maxfile (*.max)||"
		if _fileToLoad != undefined do _edtExplore.text = _fileToLoad
	)

	on _btnClose pressed do 
	(
		--
		try(DestroyDialog ::matLibExpUi) catch()
	)
)

-- POST

if _checkPrefFile.count != 0 then
(
	_rolloutPosition = execute(getIniSetting _prefFile "Window_Position" "position")
	createDialog matLibExpUi _width _height _rolloutPosition.x _rolloutPosition.y style:_rolloutStyle
)
else
(
	createDialog matLibExpUi _width _height style:_rolloutStyle
)