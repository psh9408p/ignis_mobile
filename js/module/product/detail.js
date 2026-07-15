$('#tabProduct a').on('click', function(e) {
    var oTarget = $(this).attr('href');
    $(this).parent('li').addClass('selected').siblings().removeClass('selected');

    $('#tabProduct a').each(function() {
        var oSiblings = $(this).attr('href');
        if (oTarget != oSiblings) {
            $(oSiblings).hide();
        } else {
            $(oTarget).show();
        }
    });
    removePagingArea(oTarget);
});

function removePagingArea(oTarget)
{
    if ($(oTarget).length < 1 && (oTarget != '#prdReview' || oTarget != '#prdQna')) return;

    if ($(oTarget).css('display') == 'block') {
        if (oTarget == '#prdReview') {
            var record = $('.xans-record-', '.xans-product-review').first();
            if (record.length < 1 || record.is(':not(:visible)')) {
                $('.xans-product-reviewpaging').remove();
            }
        } else if (oTarget == '#prdQnA') {
            var record = $('.xans-record-', '.xans-product-qna').first();
            if (record.length < 1 || record.is(':not(:visible)')) {
                $('.xans-product-qnapaging').remove();
            }
        }
    }
}

$(function() {
    initNativeOptionLayerBridge();

    function productDetailOrigin() {
        var imgChk = $('#prdDetailContent').find('img').length;
        if (imgChk <= 0) {
            $('#prdDetailBtn').remove();
        }
    }
    productDetailOrigin();

    var oTarget = $('.xans-product-mobileimage ul li');
    var oAppend = oTarget.first().children('p').clone();

    oTarget.slice(1).each(function() {
        var listHtml = $(this).html();
        $(this).children().wrap(function() {
            return '<p class="thumbnail">' + oAppend.html() + listHtml + '</p>';
        });

        $(this).children('p').children('img').first().remove();
    });
});

function initNativeOptionLayerBridge() {
    $('#actionWishClone, #actionWishSoldoutClone').off().on('click', function() {
        try {
            var id = $(this).attr('id').replace(/Clone/g, '');
            if (typeof(id) !== 'undefined') $('#' + id).trigger('click');
            else return false;
        } catch(e) {
            return false;
        }
    });

    bindFixedActionOptionSheet();
}

function bindFixedActionOptionSheet() {
    if (window.__nativeOptionLayerCaptureBound) return;

    window.__nativeOptionLayerCaptureBound = true;
    document.addEventListener('click', handleFixedActionOptionSheet, true);
}

function handleFixedActionOptionSheet(event) {
    var target = event.target;
    var trigger = target && target.closest ? target.closest('#orderFixArea .btnStrong, #actionCartClone') : null;

    if (!trigger) return;

    event.preventDefault();
    event.stopImmediatePropagation();
    openNativeOptionLayer();
}

function openNativeOptionLayer() {
    var url = getNativeOptionLayerUrl();
    var $existingLayer = $('#ec_temp_mobile_layer');

    $('body').addClass('buy-option-layer-open');

    if ($existingLayer.length) {
        $('html, body').css({'overflowY': 'hidden', height: '100%', width: '100%'});
        $existingLayer.show();
        scheduleNativeOptionLayerFrameSync();
        return;
    }

    if (typeof globalLayerOpenFunc === 'function') {
        globalLayerOpenFunc($('<a>', {
            href: '#none'
        }).data('url', url));
        scheduleNativeOptionLayerFrameSync();
        return;
    }

    var $originalBuy = $('.buy-original-actions .btnStrong, [id!="orderFixArea"] .xans-product-action .btnStrong').first();
    if ($originalBuy.length) {
        $originalBuy.trigger('click');
    }
}

function getNativeOptionLayerUrl() {
    var path = window.location.pathname;
    var search = window.location.search || '';
    var productNo = getQueryValue('product_no');
    var cateNo = getQueryValue('cate_no');
    var displayGroup = getQueryValue('display_group');
    var pathMatch = path.match(/\/([0-9]+)\/category\/([0-9]+)\/display\/([0-9]+)/);

    if (pathMatch) {
        productNo = productNo || pathMatch[1];
        cateNo = cateNo || pathMatch[2];
        displayGroup = displayGroup || pathMatch[3];
    }

    if (!productNo) {
        var fallbackMatch = path.match(/\/([0-9]+)(?:\/)?$/);
        productNo = fallbackMatch ? fallbackMatch[1] : '';
    }

    var params = [];
    if (productNo) params.push('product_no=' + encodeURIComponent(productNo));
    if (cateNo) params.push('cate_no=' + encodeURIComponent(cateNo));
    if (displayGroup) params.push('display_group=' + encodeURIComponent(displayGroup));

    if (!params.length && search) {
        return '/product/layer_option.html' + search;
    }

    return '/product/layer_option.html' + (params.length ? '?' + params.join('&') : '');
}

function getQueryValue(key) {
    var query = window.location.search.replace(/^\?/, '').split('&');
    var pair;

    for (var i = 0; i < query.length; i++) {
        pair = query[i].split('=');
        if (pair[0] === key) {
            return decodeURIComponent(pair[1] || '');
        }
    }

    return '';
}

function scheduleNativeOptionLayerFrameSync() {
    window.setTimeout(syncNativeOptionLayerFrame, 30);
    window.setTimeout(syncNativeOptionLayerFrame, 150);
    window.setTimeout(syncNativeOptionLayerFrame, 500);
    window.setTimeout(syncNativeOptionLayerFrame, 1000);
}

function syncNativeOptionLayerFrame() {
    $('#ec_temp_mobile_layer').css({
        position: 'fixed',
        top: 0,
        right: 0,
        bottom: 0,
        left: 0,
        width: '100%',
        height: '100dvh',
        zIndex: 9999
    });

    $('#ec_temp_mobile_iframe_layer').css({
        display: 'block',
        width: '100%',
        height: '100%',
        border: 0
    });
}
