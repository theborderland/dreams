!function(e){"use strict";var t="calc(100%)";e.widget("gu.budgetprogressbar",{options:{parts:[{value:0,barClass:"",text:!1,textClass:""}]},_create:function(){var r=this;r._createOptionsFromData(),r._isAnyDataGiven()&&(r.element.addClass("budgetprogressbar"),r.progressRoot=r._createProgressRoot(),r.progressBottomText=r._createProgressBottomText(),r.progressHoverBar=r._createProgressHoverBar(),r.progressRoot.progressbar({value:0,disabled:r.options.disabled}),r.progressRoot.addClass("gb-budgetprogressbar"),r.progressRoot.css("width",t),r._createPartsFromOptions(),r._partTemplate=r._getPartElements()[0],r._createParts(r.options.parts),e.extend(r,{created:!0}))},_isAnyDataGiven:function(){var e=this;return e.options.min||e.options.max||e.options.value},_createOptionsFromData:function(){var e=this;(e.element.data("min")||e.element.data("max")||e.element.data("value"))&&(e.options.min=e.element.data("min"),e.options.max=e.element.data("max"),e.options.value=e.element.data("value"))},_createPartsFromOptions:function(){var e=this;e.options.parts=[];var t=e.options.value<e.options.min?"minBarValue":"minCrossedBarValue",r=e.options.value/e.options.max*100,a={value:r,barClass:t};e.options.parts.push(a)},_createProgressRoot:function(){var t=this,r=e("<div class='progressbar-main'></div>");return t.element.append(r),r},_createProgressBottomText:function(){var r=this,a=e("<div></div>").addClass("progressbar-bottomText").css("width",t);return r.element.append(a),a},_createProgressHoverBar:function(){var t=this,r=e("<div></div>").addClass("progressbar-hoverBar");return t.element.append(r),r},_getPartElements:function(){return this.progressRoot.children(".ui-progressbar-value")},_createParts:function(t){var r=this;r._getPartElements().remove();var a=!0,s=null,o=0;e.each(t,function(t,n){var i=e(r._partTemplate).appendTo(r.progressRoot);if(i.removeClass("ui-corner-left"),n.value>=0&&100>o){a=!1,n.value=o+n.value>100?100-o:n.value,i.css("width","calc("+n.value+"% + 2px)").show(),s=i,o+=n.value;var p=r.options.min/r.options.max*100,l=r.options.min.toString();r.options.min<10&&(l="\xa0"+l),l&&0!=l.length||(l="\xa0"),e("<div></div>").addClass("minCrossedHoverBar").css("margin-right","calc("+p+"% + 2px)").appendTo(r.progressBottomText),e("<div></div>").addClass("minCrossedBarText").css("margin-right","calc("+p+"% - 0.5em)").text(l).appendTo(r.progressBottomText)}else n.value=0,i.hide();if(i.addClass(n.barClass),void 0!==n.text&&null!==n.text&&n.text!==!1){var d;n.text===!0?d=Math.round(n.value)+"%":""!==e.trim(n.text)&&(d=n.text),e("<div></div>").addClass("gb-budgetprogressbar-valuetext").text(d).addClass(n.textClass).appendTo(i)}}),r.created===!0&&r._trigger("change",null,{parts:t}),o>=99.9&&(s.addClass("ui-corner-right"),r._trigger("complete"))},destroy:function(){var e=this;e._getPartElements().remove(),e.progressRoot.progressbar("destroy")},_setOption:function(t,r){var a=this;switch(e.Widget.prototype._setOption.apply(a,arguments),t){case"parts":a._createParts(r);break;case"dummy":}},total:function(){var t=this,r=0;return e.each(t.options.parts,function(e,t){r+=t.value}),r}})}(jQuery);