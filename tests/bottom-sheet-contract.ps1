$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
$layer = Get-Content -Raw (Join-Path $root 'product/layer_option.html')
$layerLayout = Get-Content -Raw (Join-Path $root 'layout/basic/layer.html')
$script = Get-Content -Raw (Join-Path $root 'js/module/product/detail.js')
$commonScript = Get-Content -Raw (Join-Path $root 'layout/basic/js/common.js')
$optionCss = Get-Content -Raw (Join-Path $root 'css/module/product/detail_option.css')
$detailCss = Get-Content -Raw (Join-Path $root 'css/module/product/detail.css')
$optionConfigPath = Join-Path $root 'js/module/product/option-picker-config.js'

if (-not (Test-Path $optionConfigPath)) {
    throw 'The option picker must load an external option metadata configuration file.'
}

$optionConfig = Get-Content -Raw $optionConfigPath

if ($layer -notmatch 'id="product_detail_option_layer" class="ec-base-layer typeWide buy-option-bottom-sheet"') {
    throw 'The option layer must use the full-height bottom-sheet class.'
}

if ($layerLayout -notmatch '<!--@css\(/css/module/product/detail_option\.css\)-->') {
    throw 'The option sheet stylesheet must be loaded from the iframe document head.'
}

if ($layerLayout -notmatch '<!--@js\(/js/module/product/option-picker-config\.js\)-->') {
    throw 'The option picker metadata configuration must be loaded by the iframe document.'
}

if ($script -notmatch "document\.addEventListener\('click', handleFixedActionOptionSheet, true\)") {
    throw 'The fixed purchase area must delegate every click to the option sheet opener.'
}

if ($commonScript -notmatch '\$area\.hasClass\(''buy-sheet-actions''\)') {
    throw 'The custom fixed purchase area must not wait for a scroll event.'
}

if ($optionCss -notmatch '#totalProducts \.delete,[\s\S]*display:block') {
    throw 'Selected option cards must expose the native delete control.'
}

if ($layer -notmatch 'function closeBuyOptionLayer\(\)' -or $layer -notmatch 'closeBuyOptionLayer\(\); return false;') {
    throw 'Closing the option sheet must hide the existing iframe instead of discarding it.'
}

if ($script -notmatch 'if \(\$existingLayer\.length\)') {
    throw 'Reopening the option sheet must reuse the existing iframe state.'
}

if ($detailCss -notmatch '\.buy-sheet-total\s*\{\s*display:none') {
    throw 'The first-screen total-set area must be hidden.'
}

if ($detailCss -notmatch '@media all and \(max-width:1024px\)' -or $detailCss -notmatch '@media all and \(min-width:1025px\)') {
    throw 'The mobile purchase UI must stay active through a 1024px viewport.'
}

if ($detailCss -match '@media all and \(min-width:569px\) and \(max-width:1024px\)[\s\S]*max-width:640px' -or $optionCss -match '@media all and \(min-width:569px\) and \(max-width:1024px\)[\s\S]*max-width:640px') {
    throw 'Tablet purchase controls and the opened option sheet must fill the viewport through 1024px.'
}

if ($optionCss -notmatch '@media all and \(max-width:1024px\)[\s\S]*buy-option-bottom-sheet[\s\S]*max-width:none') {
    throw 'The opened option sheet must remove its 480px maximum width through a 1024px viewport.'
}

if ($layer -notmatch 'buy-shipping-benefit' -or $layer -notmatch 'function updateShippingBenefit\(\)' -or $layer -notmatch 'data-free-shipping-threshold="40000"') {
    throw 'The option sheet must include a dynamic 40,000 won free-shipping benefit area.'
}

if ($layer -notmatch 'function parseOptionSlot\(text\)' -or $layer -notmatch 'function handleOptionSlotLimit\(event\)' -or $layer -notmatch "document\.addEventListener\('change', handleOptionSlotLimit, true\)" -or $layer -notmatch 'function syncOptionSlotAvailability\(\)' -or $layer -notmatch 'data-slot-original-disabled') {
    throw 'The option sheet must limit each option group by its underscore suffix slots.'
}

if ($layer -notmatch 'function renderOptionSlotPicker\(select\)' -or $layer -notmatch 'function selectNextOptionSlot\(select, base\)' -or $layer -notmatch 'function syncOptionSlotPicker\(\)' -or $layer -notmatch 'slot \? slot\.base') {
    throw 'The option sheet must hide suffixes from customers and assign the next available suffix slot internally.'
}

if ($layer -notmatch 'var rawText = optionName && optionName\.textContent;' -or $layer -notmatch 'parseOptionSlot\(rawText \|\| text\)') {
    throw 'Suffix limits must use the original option value, not the suffix-free customer label.'
}

if ($layer -notmatch 'ec-product-button li\[option_value=') {
    throw 'Grouped option buttons must invoke Cafe24 through the original option-button link.'
}

if ($layer -notmatch 'function isOriginalOptionDisabled\(option\)' -or $layer -notmatch 'option\.disabled = isOriginalOptionDisabled\(option\);') {
    throw 'Suffix tracking must not disable a selected Cafe24 option needed for checkout validation.'
}

if ($optionConfig -notmatch 'window\.OptionPickerConfig' -or $layer -notmatch 'function getOptionPickerMetadata\(base\)' -or $layer -notmatch 'metadata\.badge' -or $layer -notmatch 'metadata\.description' -or $layer -notmatch 'metadata\.recommendation') {
    throw 'Option badges, descriptions, recommendations, limits, and prices must support external metadata overrides.'
}

if ($optionCss -notmatch '#totalProducts tbody tr \{[\s\S]*border-radius:6px' -or $optionCss -notmatch '#totalProducts \.delete,[\s\S]*background:transparent') {
    throw 'Selected option cards must retain the original size and plain close-button treatment.'
}

if ($optionCss -notmatch '#totalProducts tbody td:nth-child\(2\) \{[\s\S]*right:14px;[\s\S]*bottom:14px' -or $optionCss -notmatch '#totalProducts tbody td:nth-child\(3\) \{[\s\S]*top:14px;[\s\S]*bottom:auto') {
    throw 'Selected option card price and delete controls must retain their original-sized positions.'
}

if ($layer -notmatch 'function syncOptionCardPresentation\(\)' -or $optionCss -notmatch 'data-option-title') {
    throw 'Selected option cards must present the selected option as their title.'
}

$referenceCardCss = $optionCss.Substring($optionCss.LastIndexOf('/* selected option card: reference mobile layout */'))
if ($referenceCardCss -notmatch 'height:32px' -or $referenceCardCss -notmatch 'font-size:16px') {
    throw 'Selected option card text and quantity controls must retain the original sizing.'
}

if ($optionCss -notmatch 'p\.product:before,[\s\S]*content:none') {
    throw 'Selected option cards must remove the legacy leading marker.'
}

Write-Output 'Bottom-sheet structural contract passed.'
