# lookup tables for old-style JavaScript bindings
create_hash_table := $(LOCAL_PATH)/../JavaScriptCore/create_hash_table

LOCAL_GENERATED_SOURCES += \
	$(intermediates)/bindings/js/JSDOMWindowBase.lut.h

# CSS
GEN := \
    $(intermediates)/css/JSCSSCharsetRule.h \
    $(intermediates)/css/JSCSSFontFaceRule.h \
    $(intermediates)/css/JSCSSImportRule.h \
    $(intermediates)/css/JSCSSMediaRule.h \
    $(intermediates)/css/JSCSSPageRule.h \
    $(intermediates)/css/JSCSSPrimitiveValue.h \
    $(intermediates)/css/JSCSSRule.h \
    $(intermediates)/css/JSCSSRuleList.h \
    $(intermediates)/css/JSCSSStyleDeclaration.h \
    $(intermediates)/css/JSCSSStyleRule.h \
    $(intermediates)/css/JSCSSStyleSheet.h \
    $(intermediates)/css/JSCSSUnknownRule.h \
    $(intermediates)/css/JSCSSValue.h \
    $(intermediates)/css/JSCSSValueList.h \
    $(intermediates)/css/JSCSSVariablesDeclaration.h \
    $(intermediates)/css/JSCSSVariablesRule.h \
    $(intermediates)/css/JSCounter.h \
    $(intermediates)/css/JSMedia.h \
    $(intermediates)/css/JSMediaList.h \
    $(intermediates)/css/JSRGBColor.h \
    $(intermediates)/css/JSRect.h \
    $(intermediates)/css/JSStyleSheet.h \
    $(intermediates)/css/JSStyleSheetList.h \
    $(intermediates)/css/JSWebKitCSSKeyframeRule.h \
    $(intermediates)/css/JSWebKitCSSKeyframesRule.h \
    $(intermediates)/css/JSWebKitCSSMatrix.h \
    $(intermediates)/css/JSWebKitCSSTransformValue.h
LOCAL_GENERATED_SOURCES += $(GEN) $(GEN:%.h=%.cpp)

# DOM
GEN := \
    $(intermediates)/dom/JSAttr.h \
    $(intermediates)/dom/JSBeforeLoadEvent.h \
    $(intermediates)/dom/JSCDATASection.h \
    $(intermediates)/dom/JSCharacterData.h \
    $(intermediates)/dom/JSClientRect.h \
    $(intermediates)/dom/JSClientRectList.h \
    $(intermediates)/dom/JSClipboard.h \
    $(intermediates)/dom/JSComment.h \
    $(intermediates)/dom/JSDOMCoreException.h \
    $(intermediates)/dom/JSDOMImplementation.h \
    $(intermediates)/dom/JSDocument.h \
    $(intermediates)/dom/JSDocumentFragment.h \
    $(intermediates)/dom/JSDocumentType.h \
    $(intermediates)/dom/JSElement.h \
    $(intermediates)/dom/JSEntity.h \
    $(intermediates)/dom/JSEntityReference.h \
    $(intermediates)/dom/JSErrorEvent.h \
    $(intermediates)/dom/JSEvent.h \
    $(intermediates)/dom/JSEventException.h \
    $(intermediates)/dom/JSKeyboardEvent.h \
    $(intermediates)/dom/JSMessageChannel.h \
    $(intermediates)/dom/JSMessageEvent.h \
    $(intermediates)/dom/JSMessagePort.h \
    $(intermediates)/dom/JSMouseEvent.h \
    $(intermediates)/dom/JSMutationEvent.h \
    $(intermediates)/dom/JSNamedNodeMap.h \
    $(intermediates)/dom/JSNode.h \
    $(intermediates)/dom/JSNodeFilter.h \
    $(intermediates)/dom/JSNodeIterator.h \
    $(intermediates)/dom/JSNodeList.h \
    $(intermediates)/dom/JSNotation.h \
    $(intermediates)/dom/JSOverflowEvent.h \
    $(intermediates)/dom/JSPageTransitionEvent.h \
    $(intermediates)/dom/JSProcessingInstruction.h \
    $(intermediates)/dom/JSProgressEvent.h \
    $(intermediates)/dom/JSRange.h \
    $(intermediates)/dom/JSRangeException.h \
    $(intermediates)/dom/JSText.h \
    $(intermediates)/dom/JSTextEvent.h \
    $(intermediates)/dom/JSTouch.h \
    $(intermediates)/dom/JSTouchEvent.h \
    $(intermediates)/dom/JSTouchList.h \
    $(intermediates)/dom/JSTreeWalker.h \
    $(intermediates)/dom/JSUIEvent.h \
    $(intermediates)/dom/JSWebKitAnimationEvent.h \
    $(intermediates)/dom/JSWebKitTransitionEvent.h \
    $(intermediates)/dom/JSWheelEvent.h

LOCAL_GENERATED_SOURCES += $(GEN) $(GEN:%.h=%.cpp)

# We also need the .cpp files, which are generated as side effects of the
# above rules.  Specifying this explicitly makes -j2 work.
$(patsubst %.h,%.cpp,$(GEN)): $(intermediates)/dom/%.cpp : $(intermediates)/dom/%.h

# HTML
GEN := \
    $(intermediates)/html/JSDataGridColumn.h \
    $(intermediates)/html/JSDataGridColumnList.h \
    $(intermediates)/html/JSFile.h \
    $(intermediates)/html/JSFileList.h \
    $(intermediates)/html/JSHTMLAllCollection.h \
    $(intermediates)/html/JSHTMLAnchorElement.h \
    $(intermediates)/html/JSHTMLAppletElement.h \
    $(intermediates)/html/JSHTMLAreaElement.h \
    $(intermediates)/html/JSHTMLAudioElement.h \
    $(intermediates)/html/JSHTMLBRElement.h \
    $(intermediates)/html/JSHTMLBaseElement.h \
    $(intermediates)/html/JSHTMLBaseFontElement.h \
    $(intermediates)/html/JSHTMLBlockquoteElement.h \
    $(intermediates)/html/JSHTMLBodyElement.h \
    $(intermediates)/html/JSHTMLButtonElement.h \
    $(intermediates)/html/JSHTMLCanvasElement.h \
    $(intermediates)/html/JSHTMLCollection.h \
    $(intermediates)/html/JSHTMLDataGridElement.h \
    $(intermediates)/html/JSHTMLDataGridCellElement.h \
    $(intermediates)/html/JSHTMLDataGridColElement.h \
    $(intermediates)/html/JSHTMLDataGridRowElement.h \
    $(intermediates)/html/JSHTMLDataListElement.h \
    $(intermediates)/html/JSHTMLDListElement.h \
    $(intermediates)/html/JSHTMLDirectoryElement.h \
    $(intermediates)/html/JSHTMLDivElement.h \
    $(intermediates)/html/JSHTMLDocument.h \
    $(intermediates)/html/JSHTMLElement.h \
    $(intermediates)/html/JSHTMLEmbedElement.h \
    $(intermediates)/html/JSHTMLFieldSetElement.h \
    $(intermediates)/html/JSHTMLFontElement.h \
    $(intermediates)/html/JSHTMLFormElement.h \
    $(intermediates)/html/JSHTMLFrameElement.h \
    $(intermediates)/html/JSHTMLFrameSetElement.h \
    $(intermediates)/html/JSHTMLHRElement.h \
    $(intermediates)/html/JSHTMLHeadElement.h \
    $(intermediates)/html/JSHTMLHeadingElement.h \
    $(intermediates)/html/JSHTMLHtmlElement.h \
    $(intermediates)/html/JSHTMLIFrameElement.h \
    $(intermediates)/html/JSHTMLImageElement.h \
    $(intermediates)/html/JSHTMLInputElement.h \
    $(intermediates)/html/JSHTMLIsIndexElement.h \
    $(intermediates)/html/JSHTMLLIElement.h \
    $(intermediates)/html/JSHTMLLabelElement.h \
    $(intermediates)/html/JSHTMLLegendElement.h \
    $(intermediates)/html/JSHTMLLinkElement.h \
    $(intermediates)/html/JSHTMLMapElement.h \
    $(intermediates)/html/JSHTMLMarqueeElement.h \
    $(intermediates)/html/JSHTMLMediaElement.h \
    $(intermediates)/html/JSHTMLMenuElement.h \
    $(intermediates)/html/JSHTMLMetaElement.h \
    $(intermediates)/html/JSHTMLModElement.h \
    $(intermediates)/html/JSHTMLOListElement.h \
    $(intermediates)/html/JSHTMLObjectElement.h \
    $(intermediates)/html/JSHTMLOptGroupElement.h \
    $(intermediates)/html/JSHTMLOptionElement.h \
    $(intermediates)/html/JSHTMLOptionsCollection.h \
    $(intermediates)/html/JSHTMLParagraphElement.h \
    $(intermediates)/html/JSHTMLParamElement.h \
    $(intermediates)/html/JSHTMLPreElement.h \
    $(intermediates)/html/JSHTMLQuoteElement.h \
    $(intermediates)/html/JSHTMLScriptElement.h \
    $(intermediates)/html/JSHTMLSelectElement.h \
    $(intermediates)/html/JSHTMLSourceElement.h \
    $(intermediates)/html/JSHTMLStyleElement.h \
    $(intermediates)/html/JSHTMLTableCaptionElement.h \
    $(intermediates)/html/JSHTMLTableCellElement.h \
    $(intermediates)/html/JSHTMLTableColElement.h \
    $(intermediates)/html/JSHTMLTableElement.h \
    $(intermediates)/html/JSHTMLTableRowElement.h \
    $(intermediates)/html/JSHTMLTableSectionElement.h \
    $(intermediates)/html/JSHTMLTextAreaElement.h \
    $(intermediates)/html/JSHTMLTitleElement.h \
    $(intermediates)/html/JSHTMLUListElement.h \
    $(intermediates)/html/JSHTMLVideoElement.h \
    $(intermediates)/html/JSImageData.h \
    $(intermediates)/html/JSMediaError.h \
    $(intermediates)/html/JSTextMetrics.h \
    $(intermediates)/html/JSTimeRanges.h \
    $(intermediates)/html/JSValidityState.h \
    $(intermediates)/html/JSVoidCallback.h
LOCAL_GENERATED_SOURCES += $(GEN) $(GEN:%.h=%.cpp)

# Canvas
GEN := \
    $(intermediates)/html/canvas/JSCanvasActiveInfo.h \
    $(intermediates)/html/canvas/JSCanvasArray.h \
    $(intermediates)/html/canvas/JSCanvasArrayBuffer.h \
    $(intermediates)/html/canvas/JSCanvasBuffer.h \
    $(intermediates)/html/canvas/JSCanvasByteArray.h \
    $(intermediates)/html/canvas/JSCanvasFloatArray.h \
    $(intermediates)/html/canvas/JSCanvasFramebuffer.h \
    $(intermediates)/html/canvas/JSCanvasGradient.h \
    $(intermediates)/html/canvas/JSCanvasIntArray.h \
    $(intermediates)/html/canvas/JSCanvasNumberArray.h \
    $(intermediates)/html/canvas/JSCanvasPattern.h \
    $(intermediates)/html/canvas/JSCanvasProgram.h \
    $(intermediates)/html/canvas/JSCanvasRenderbuffer.h \
    $(intermediates)/html/canvas/JSCanvasRenderingContext.h \
    $(intermediates)/html/canvas/JSCanvasRenderingContext2D.h \
    $(intermediates)/html/canvas/JSCanvasRenderingContext3D.h \
    $(intermediates)/html/canvas/JSCanvasShader.h \
    $(intermediates)/html/canvas/JSCanvasShortArray.h \
    $(intermediates)/html/canvas/JSCanvasTexture.h \
    $(intermediates)/html/canvas/JSCanvasUnsignedByteArray.h \
    $(intermediates)/html/canvas/JSCanvasUnsignedIntArray.h \
    $(intermediates)/html/canvas/JSCanvasUnsignedShortArray.h
LOCAL_GENERATED_SOURCES += $(GEN) $(GEN:%.h=%.cpp)

# Appcache
GEN := \
    $(intermediates)/loader/appcache/JSDOMApplicationCache.h
LOCAL_GENERATED_SOURCES += $(GEN) $(GEN:%.h=%.cpp)

# page
GEN := \
    $(intermediates)/page/JSBarInfo.h \
    $(intermediates)/page/JSConsole.h \
    $(intermediates)/page/JSCoordinates.h \
    $(intermediates)/page/JSDOMSelection.h \
    $(intermediates)/page/JSDOMWindow.h \
    $(intermediates)/page/JSGeolocation.h \
    $(intermediates)/page/JSGeoposition.h \
    $(intermediates)/page/JSHistory.h \
    $(intermediates)/page/JSLocation.h \
    $(intermediates)/page/JSNavigator.h \
    $(intermediates)/page/JSPositionError.h \
    $(intermediates)/page/JSScreen.h \
    $(intermediates)/page/JSWebKitPoint.h \
    $(intermediates)/page/JSWorkerNavigator.h
LOCAL_GENERATED_SOURCES += $(GEN) $(GEN:%.h=%.cpp)

GEN := \
    $(intermediates)/plugins/JSMimeType.h \
    $(intermediates)/plugins/JSMimeTypeArray.h \
    $(intermediates)/plugins/JSPlugin.h \
    $(intermediates)/plugins/JSPluginArray.h
LOCAL_GENERATED_SOURCES += $(GEN) $(GEN:%.h=%.cpp)

# Database
GEN := \
    $(intermediates)/storage/JSDatabase.h \
    $(intermediates)/storage/JSSQLError.h \
    $(intermediates)/storage/JSSQLResultSet.h \
    $(intermediates)/storage/JSSQLResultSetRowList.h \
    $(intermediates)/storage/JSSQLTransaction.h
LOCAL_GENERATED_SOURCES += $(GEN) $(GEN:%.h=%.cpp)

# DOM Storage
GEN := \
    $(intermediates)/storage/JSStorage.h \
    $(intermediates)/storage/JSStorageEvent.h
LOCAL_GENERATED_SOURCES += $(GEN) $(GEN:%.h=%.cpp)

# SVG
ifeq ($(ENABLE_SVG), true)
GEN := \
    $(intermediates)/svg/JSSVGAElement.h \
    $(intermediates)/svg/JSSVGAltGlyphElement.h \
    $(intermediates)/svg/JSSVGAngle.h \
    $(intermediates)/svg/JSSVGAnimateColorElement.h \
    $(intermediates)/svg/JSSVGAnimateElement.h \
    $(intermediates)/svg/JSSVGAnimateTransformElement.h \
    $(intermediates)/svg/JSSVGAnimatedAngle.h \
    $(intermediates)/svg/JSSVGAnimatedBoolean.h \
    $(intermediates)/svg/JSSVGAnimatedEnumeration.h \
    $(intermediates)/svg/JSSVGAnimatedInteger.h \
    $(intermediates)/svg/JSSVGAnimatedLength.h \
    $(intermediates)/svg/JSSVGAnimatedLengthList.h \
    $(intermediates)/svg/JSSVGAnimatedNumber.h \
    $(intermediates)/svg/JSSVGAnimatedNumberList.h \
    $(intermediates)/svg/JSSVGAnimatedPreserveAspectRatio.h \
    $(intermediates)/svg/JSSVGAnimatedRect.h \
    $(intermediates)/svg/JSSVGAnimatedString.h \
    $(intermediates)/svg/JSSVGAnimatedTransformList.h \
    $(intermediates)/svg/JSSVGAnimationElement.h \
    $(intermediates)/svg/JSSVGCircleElement.h \
    $(intermediates)/svg/JSSVGClipPathElement.h \
    $(intermediates)/svg/JSSVGColor.h \
    $(intermediates)/svg/JSSVGComponentTransferFunctionElement.h \
    $(intermediates)/svg/JSSVGCursorElement.h \
    $(intermediates)/svg/JSSVGDefsElement.h \
    $(intermediates)/svg/JSSVGDescElement.h \
    $(intermediates)/svg/JSSVGDocument.h \
    $(intermediates)/svg/JSSVGElement.h \
    $(intermediates)/svg/JSSVGElementInstance.h \
    $(intermediates)/svg/JSSVGElementInstanceList.h \
    $(intermediates)/svg/JSSVGEllipseElement.h \
    $(intermediates)/svg/JSSVGException.h \
    $(intermediates)/svg/JSSVGFEBlendElement.h \
    $(intermediates)/svg/JSSVGFEColorMatrixElement.h \
    $(intermediates)/svg/JSSVGFEComponentTransferElement.h \
    $(intermediates)/svg/JSSVGFECompositeElement.h \
    $(intermediates)/svg/JSSVGFEDiffuseLightingElement.h \
    $(intermediates)/svg/JSSVGFEDisplacementMapElement.h \
    $(intermediates)/svg/JSSVGFEDistantLightElement.h \
    $(intermediates)/svg/JSSVGFEFloodElement.h \
    $(intermediates)/svg/JSSVGFEFuncAElement.h \
    $(intermediates)/svg/JSSVGFEFuncBElement.h \
    $(intermediates)/svg/JSSVGFEFuncGElement.h \
    $(intermediates)/svg/JSSVGFEFuncRElement.h \
    $(intermediates)/svg/JSSVGFEGaussianBlurElement.h \
    $(intermediates)/svg/JSSVGFEImageElement.h \
    $(intermediates)/svg/JSSVGFEMergeElement.h \
    $(intermediates)/svg/JSSVGFEMergeNodeElement.h \
    $(intermediates)/svg/JSSVGFEOffsetElement.h \
    $(intermediates)/svg/JSSVGFEPointLightElement.h \
    $(intermediates)/svg/JSSVGFESpecularLightingElement.h \
    $(intermediates)/svg/JSSVGFESpotLightElement.h \
    $(intermediates)/svg/JSSVGFETileElement.h \
    $(intermediates)/svg/JSSVGFETurbulenceElement.h \
    $(intermediates)/svg/JSSVGFilterElement.h \
    $(intermediates)/svg/JSSVGFontElement.h \
    $(intermediates)/svg/JSSVGFontFaceElement.h \
    $(intermediates)/svg/JSSVGFontFaceFormatElement.h \
    $(intermediates)/svg/JSSVGFontFaceNameElement.h \
    $(intermediates)/svg/JSSVGFontFaceSrcElement.h \
    $(intermediates)/svg/JSSVGFontFaceUriElement.h \
    $(intermediates)/svg/JSSVGForeignObjectElement.h \
    $(intermediates)/svg/JSSVGGElement.h \
    $(intermediates)/svg/JSSVGGlyphElement.h \
    $(intermediates)/svg/JSSVGGradientElement.h \
    $(intermediates)/svg/JSSVGHKernElement.h \
    $(intermediates)/svg/JSSVGImageElement.h \
    $(intermediates)/svg/JSSVGLength.h \
    $(intermediates)/svg/JSSVGLengthList.h \
    $(intermediates)/svg/JSSVGLineElement.h \
    $(intermediates)/svg/JSSVGLinearGradientElement.h \
    $(intermediates)/svg/JSSVGMarkerElement.h \
    $(intermediates)/svg/JSSVGMaskElement.h \
    $(intermediates)/svg/JSSVGMatrix.h \
    $(intermediates)/svg/JSSVGMetadataElement.h \
    $(intermediates)/svg/JSSVGMissingGlyphElement.h \
    $(intermediates)/svg/JSSVGNumber.h \
    $(intermediates)/svg/JSSVGNumberList.h \
    $(intermediates)/svg/JSSVGPaint.h \
    $(intermediates)/svg/JSSVGPathElement.h \
    $(intermediates)/svg/JSSVGPathSeg.h \
    $(intermediates)/svg/JSSVGPathSegArcAbs.h \
    $(intermediates)/svg/JSSVGPathSegArcRel.h \
    $(intermediates)/svg/JSSVGPathSegClosePath.h \
    $(intermediates)/svg/JSSVGPathSegCurvetoCubicAbs.h \
    $(intermediates)/svg/JSSVGPathSegCurvetoCubicRel.h \
    $(intermediates)/svg/JSSVGPathSegCurvetoCubicSmoothAbs.h \
    $(intermediates)/svg/JSSVGPathSegCurvetoCubicSmoothRel.h \
    $(intermediates)/svg/JSSVGPathSegCurvetoQuadraticAbs.h \
    $(intermediates)/svg/JSSVGPathSegCurvetoQuadraticRel.h \
    $(intermediates)/svg/JSSVGPathSegCurvetoQuadraticSmoothAbs.h \
    $(intermediates)/svg/JSSVGPathSegCurvetoQuadraticSmoothRel.h \
    $(intermediates)/svg/JSSVGPathSegLinetoAbs.h \
    $(intermediates)/svg/JSSVGPathSegLinetoHorizontalAbs.h \
    $(intermediates)/svg/JSSVGPathSegLinetoHorizontalRel.h \
    $(intermediates)/svg/JSSVGPathSegLinetoRel.h \
    $(intermediates)/svg/JSSVGPathSegLinetoVerticalAbs.h \
    $(intermediates)/svg/JSSVGPathSegLinetoVerticalRel.h \
    $(intermediates)/svg/JSSVGPathSegList.h \
    $(intermediates)/svg/JSSVGPathSegMovetoAbs.h \
    $(intermediates)/svg/JSSVGPathSegMovetoRel.h \
    $(intermediates)/svg/JSSVGPatternElement.h \
    $(intermediates)/svg/JSSVGPoint.h \
    $(intermediates)/svg/JSSVGPointList.h \
    $(intermediates)/svg/JSSVGPolygonElement.h \
    $(intermediates)/svg/JSSVGPolylineElement.h \
    $(intermediates)/svg/JSSVGPreserveAspectRatio.h \
    $(intermediates)/svg/JSSVGRadialGradientElement.h \
    $(intermediates)/svg/JSSVGRect.h \
    $(intermediates)/svg/JSSVGRectElement.h \
    $(intermediates)/svg/JSSVGRenderingIntent.h \
    $(intermediates)/svg/JSSVGSVGElement.h \
    $(intermediates)/svg/JSSVGScriptElement.h \
    $(intermediates)/svg/JSSVGSetElement.h \
    $(intermediates)/svg/JSSVGStopElement.h \
    $(intermediates)/svg/JSSVGStringList.h \
    $(intermediates)/svg/JSSVGStyleElement.h \
    $(intermediates)/svg/JSSVGSwitchElement.h \
    $(intermediates)/svg/JSSVGSymbolElement.h \
    $(intermediates)/svg/JSSVGTRefElement.h \
    $(intermediates)/svg/JSSVGTSpanElement.h \
    $(intermediates)/svg/JSSVGTextContentElement.h \
    $(intermediates)/svg/JSSVGTextElement.h \
    $(intermediates)/svg/JSSVGTextPathElement.h \
    $(intermediates)/svg/JSSVGTextPositioningElement.h \
    $(intermediates)/svg/JSSVGTitleElement.h \
    $(intermediates)/svg/JSSVGTransform.h \
    $(intermediates)/svg/JSSVGTransformList.h \
    $(intermediates)/svg/JSSVGUnitTypes.h \
    $(intermediates)/svg/JSSVGUseElement.h \
    $(intermediates)/svg/JSSVGViewElement.h \
    $(intermediates)/svg/JSSVGZoomEvent.h
LOCAL_GENERATED_SOURCES += $(GEN) $(GEN:%.h=%.cpp)
endif

# Workers
GEN := \
    $(intermediates)/workers/JSAbstractWorker.h \
    $(intermediates)/workers/JSDedicatedWorkerContext.h \
    $(intermediates)/workers/JSSharedWorker.h \
    $(intermediates)/workers/JSSharedWorkerContext.h \
    $(intermediates)/workers/JSWorker.h \
    $(intermediates)/workers/JSWorkerContext.h \
    $(intermediates)/workers/JSWorkerLocation.h
LOCAL_GENERATED_SOURCES += $(GEN) $(GEN:%.h=%.cpp)

# XML
GEN := \
    $(intermediates)/xml/JSDOMParser.h \
    $(intermediates)/xml/JSXMLHttpRequest.h \
    $(intermediates)/xml/JSXMLHttpRequestException.h \
    $(intermediates)/xml/JSXMLHttpRequestProgressEvent.h \
    $(intermediates)/xml/JSXMLHttpRequestUpload.h \
    $(intermediates)/xml/JSXMLSerializer.h \
    $(intermediates)/xml/JSXSLTProcessor.h
LOCAL_GENERATED_SOURCES += $(GEN) $(GEN:%.h=%.cpp)

# HTML tag and attribute names

GEN:= $(intermediates)/HTMLNames.cpp $(intermediates)/HTMLElementFactory.cpp  $(intermediates)/JSHTMLElementWrapperFactory.cpp
LOCAL_GENERATED_SOURCES += $(GEN)

# SVG tag and attribute names

ifeq ($(ENABLE_SVG), true)
GEN:= $(intermediates)/SVGNames.cpp  $(intermediates)/SVGElementFactory.cpp $(intermediates)/JSSVGElementWrapperFactory.cpp
LOCAL_GENERATED_SOURCES += $(GEN)
endif
