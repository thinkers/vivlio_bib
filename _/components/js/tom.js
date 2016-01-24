var tom = {

	breakpoint    : {
		XSPHONE         : 'XSPHONE',
		PHONE           : 'PHONE',
		TABLET          : 'TABLET',
		MEDIUM          : 'MEDIUM',
		LARGE           : 'LARGE',
		CURRENT         : null
	},

	button        : {
		pressed         : false,
		mousePos        : 0,
		locked          : false,
		timeout         : null,
		LOCK_TEXT       : 'LOCK →',
		UNLOCK_TEXT     : '← UNLOCK',
		MAGIC_TEXT      : 'MAGIC'
	},

	selectors     : [
		'.was-orig',
		'span[data-type="obRef"]',
		'span[data-type="placeRef"]',
		'span[data-type="persRef"]'
	],

	milestones    : [],
	anchors       : [],
	offset        : {
		MOBILE          : 105,
		FULL            : 80,
		CURRENT         : 0
	},

	lastScrollTop : 0,

	init: function() {
		$button_link = $('.nav__item--magic');
		$button      = $('.magic-button-circle');

		$button_link.swipe( {
	        hold: function() {
	        	tom.button.pressed = true;
	        	$button.removeClass('unpressed').addClass('pressed');
	        	if (!tom.button.locked) {
	        		tom.showLockText();
	        		tom.highlightElements();
	        	}
	        },
	        swipe: function(event, direction, distance, duration, fingerCount, fingerData) {
	        	if (direction == 'right' && tom.button.pressed) {
	        		tom.lockMagicButton();
	        	}
	        	else if ( (direction == 'left' || direction == null) && tom.button.locked ) {
	        		$button.removeClass('locked');
					tom.button.locked = false;
					tom.removeLockText();
					tom.unhighlightElements();
	        	}
	        	else if (tom.button.locked) {
	        		return;
	        	}
	        	else {
	        		tom.button.pressed = false;
	        		$button.removeClass('pressed').addClass('unpressed');
	        		tom.removeLockText();
	        		if (tom.button.locked)
	        			tom.unhighlightElements();
	        		else
	        			tom.unhighlightElementsTimeout();
	        	}
	        },
	        threshold: 0,
	        longTapThreshold: 0
		});

		$('.nav__item--home').on('click', function() {
			location.href = 'index.html';
		});

		tom.setBreakpoint();

		Breakpoints.on({
		    name: tom.breakpoint.XSPHONE,
		    matched: function() {
		    	tom.breakpoint.CURRENT = tom.breakpoint.XSPHONE;
		    	tom.showMobileHeader();
		    	tom.showMenuText();
		    }
		});
		Breakpoints.on({
		    name: tom.breakpoint.PHONE,
		    matched: function() {
		    	tom.breakpoint.CURRENT = tom.breakpoint.PHONE;
		    	tom.showMobileHeader();
		    	tom.showMenuText();
		    }
		});
		Breakpoints.on({
		    name: tom.breakpoint.TABLET,
		    matched: function() {
		    	tom.breakpoint.CURRENT = tom.breakpoint.TABLET;
		    	tom.hideMobileHeader();
		    }
		});
		Breakpoints.on({
		    name: tom.breakpoint.MEDIUM,
		    matched: function() {
		    	tom.breakpoint.CURRENT = tom.breakpoint.MEDIUM;
		    	tom.hideMobileHeader();
		    }
		});
		Breakpoints.on({
		    name: tom.breakpoint.LARGE,
		    matched: function() {
		    	tom.breakpoint.CURRENT = tom.breakpoint.LARGE;
		    	tom.hideMobileHeader();
		    }
		});

		$(window)
		.on("scrollstart", function() {
			var st = $(this).scrollTop();
			if (st > tom.lastScrollTop)
				tom.hideMenuText();
			else
				tom.showMenuText();
			tom.lastScrollTop = st;
		})
		.on("scrollstop", function() {
			var st = $(this).scrollTop();
			if (!st)
				tom.showMenuText();
			else
				tom.hideMenuText();
			tom.lastScrollTop = st;
		});
	},

	lockMagicButton: function() {
		tom.button.locked = true;
		$button.addClass('locked');
		tom.showUnlockText();
		clearTimeout(tom.button.timeout);
		tom.highlightElements();
	},

	setBreakpoint: function() {
		tom.breakpoint.CURRENT = window.getComputedStyle(document.querySelector('body'), ':after').getPropertyValue('content');
		if ( tom.breakpoint.CURRENT == tom.breakpoint.XSPHONE || tom.breakpoint.CURRENT == tom.breakpoint.PHONE )
			tom.offset.CURRENT = tom.offset.MOBILE;
		else
			tom.offset.CURRENT = tom.offset.FULL;
		console.log(tom.breakpoint.CURRENT+" "+tom.offset.CURRENT);
	},

	showMobileHeader: function() {
		$('#mobile-header').addClass('show');
	},
	hideMobileHeader: function() {
		$('#mobile-header').removeClass('show');
	},

	loadChapter: function(chapterId) {
		$( "#read" ).load(chapterId + '.xhtml #' + chapterId, function() {
			console.log("chapter "+ chapterId +" loaded!");
			tom.stickyHeader();
			tom.anchorsInit();
			tom.emptyDrawer();
			tom.highlightsInit();
		});
	},
	loadNavdrop: function(chapterId) {
		var file = 'outline/' + chapterId + '.html';
		var height = 0;

		var adjustHeight = function() {
			//var height = 0;
			$('#navdrop > section').height( $( window ).height() - 50 );//- $('#navdrop').parent().height() );
			height = $('#navdrop > section').height() + 100;
			setNavPos();
		};
		var setNavPos = function() {
			var position = {
				'top' : -height
			};
			$('#navdrop').css(position);
		};

		$('#navdrop').load(file, function() {
			adjustHeight();
			$('#navdrop').css('display', 'block');
			tom.navScrollTo();
		});

		//$(window).resize( adjustHeight );

		$('.nav__symbol--toc').on('click', function() {
			if ( $('#navdrop').hasClass('hide') ) {

				$('body').addClass('donotscroll');
				$('#navdrop').removeClass('hide');

				tom.addTouchMoveListeners();

				var headersHeight = 0;
				if ( tom.breakpoint.CURRENT == tom.breakpoint.XSPHONE || tom.breakpoint.CURRENT == tom.breakpoint.PHONE ) {
					headersHeight = 0;
					$('#mobile-header').css('visibility', 'hidden');
				}
				else
					headersHeight = 50;


				$('#navdrop').animate(
					{ top: -headersHeight }
					, 500
					, function() {
						$(this).removeClass('hide');
						$('.symbol--toc').addClass('open');
					}
				);
			}
			else {
				$('body').removeClass('donotscroll');
				$('#navdrop').addClass('hide');

				tom.removeTouchMoveListeners();

				$('#navdrop').animate(
					{ top: -height }
					, 500
					, function() {
						$(this).addClass('hide');
						$('.symbol--toc').removeClass('open');

						if ( tom.breakpoint.CURRENT == tom.breakpoint.XSPHONE || tom.breakpoint.CURRENT == tom.breakpoint.PHONE )
							$('#mobile-header').css('visibility', 'visible');
					}
				);
			}
		});
	},
	preventDefault: function(e) {
		e.preventDefault();
	},
	stopPropagation: function(e) {
		e.stopPropagation();
	},
	addTouchMoveListeners: function() {
		$(document)[0].addEventListener('touchmove', tom.preventDefault, false);
		$('#navdrop')[0].addEventListener('touchmove', tom.stopPropagation, false);
	},
	removeTouchMoveListeners: function() {
		$(document)[0].removeEventListener('touchmove', tom.preventDefault, false);
		$('#navdrop')[0].removeEventListener('touchmove', tom.stopPropagation, false);
	},

	stickyHeader: function() {
		$elem = $('h1.was-head');
		var sticky  = new Waypoint.Sticky({
			element: $elem[0],
			handler: function(direction) {
				if ( ! (tom.breakpoint.CURRENT == tom.breakpoint.XSPHONE || tom.breakpoint.CURRENT == tom.breakpoint.PHONE) ) {
					if (direction == 'down')

						$('.chapter__title').hide().append($elem.text()).fadeIn();
					else
						$('.chapter__title').empty();
				}
			},
			offset: tom.offset.CURRENT
		});
	},
	anchorsInit: function() {
		tom.stickyMilestones();
		tom.stickyAnchors();
	},

	stickyMilestones: function() {
		$('.was-milestone').each(function(index, item) {
			var $elem  = $(item);
			var sticky = new Waypoint.Sticky({
				element: $elem[0],
				handler: function(direction) {
					if (direction == 'down')
						tom.addMilestone($elem);
					else
						tom.removeMilestone($elem);
				},
				offset: tom.offset.CURRENT
			});
		});
	},
	addMilestone: function($elem) {
		if ( tom.breakpoint.CURRENT == tom.breakpoint.XSPHONE || tom.breakpoint.CURRENT == tom.breakpoint.PHONE ) {
			scene  = '.mobile__header--scene';
			anchor = '.mobile__header--anchor';
		}
		else {
			scene  = '.chapter__milestone';
			anchor = '.chapter__anchor';
		}
		tom.milestones.unshift($elem);
		$(scene).hide().empty().append('SC: ' + tom.milestones[0].text()).fadeIn();
		$(anchor).hide().empty();
	},
	removeMilestone: function($elem) {
		var anchor       = tom.milestones.shift($elem),
			anchor_sel   = '',
			milesone_sel = '';
		if ( tom.breakpoint.CURRENT == tom.breakpoint.XSPHONE || tom.breakpoint.CURRENT == tom.breakpoint.PHONE ) {
			milesone_sel = '.mobile__header--scene';
			anchor_sel   = '.mobile__header--anchor';
		}
		else {
			milesone_sel = '.chapter__milestone';
			anchor_sel   = '.chapter__anchor';
		}
		if (tom.milestones.length) {
			$(milesone_sel).hide().empty().append('SC: ' + tom.milestones[0].text()).fadeIn();
			$(anchor_sel).hide().empty().append(tom.anchors[0].text()).fadeIn();
		}
		else
			$(milesone_sel).hide().empty();
	},

	stickyAnchors: function() {
		$('.was-anchor').each(function(index, item) {
			var $elem  = $(item);
			var sticky = new Waypoint.Sticky({
				element: $elem[0],
				handler: function(direction) {
					if (direction == 'down')
						tom.addAnchor($elem);
					else
						tom.removeAnchor($elem);
				},
				offset: tom.offset.CURRENT
			});
		});
	},
	addAnchor: function($elem) {
		if ( tom.breakpoint.CURRENT == tom.breakpoint.XSPHONE || tom.breakpoint.CURRENT == tom.breakpoint.PHONE )
			anchor = '.mobile__header--anchor';
		else
			anchor = '.chapter__anchor';
		tom.anchors.unshift($elem);
		$(anchor).hide().empty().append(tom.anchors[0].text()).fadeIn();
	},
	removeAnchor: function($elem) {
		var anchor       = tom.anchors.shift($elem),
			anchor_sel   = '';
		if ( tom.breakpoint.CURRENT == tom.breakpoint.XSPHONE || tom.breakpoint.CURRENT == tom.breakpoint.PHONE )
			anchor_sel = '.mobile__header--anchor';
		else
			anchor_sel = '.chapter__anchor';
		if (tom.anchors.length)
			$(anchor_sel).hide().empty().append(tom.anchors[0].text()).fadeIn();
		else
			$(anchor_sel).hide().empty();
	},

	highlightsInit: function() {
		const ARDUINO_API_BASE_URL = 'http://vivlioyun.local/arduino/';
		const ARDUINO_API_LED_ON   = '/1';
		const ARDUINO_API_LED_OFF  = '/0';

		$('span[data-type="obRef"], span[data-type="placeRef"], span[data-type="persRef"]').on('click', function() {

			if ( !tom.button.locked)
				tom.lockMagicButton();

			tom.highlightElement($(this));

			tom.emptyDrawer();
			var $this = $(this),
			    figurl = $this.data('figure-url'),
			    figalt = $this.data('figure-alt'),
			    figsrc = $this.data('figure-source'),
			    figavl = $this.data('figure-avail'),
			    title = $this.data('name'),
			    desc  = $this.data('desc'),
			    birth = $this.data('birth'),
			    death = $this.data('death')
			    ;

			$('.drawer__item--content').removeClass('distinct');

			if (figurl) $('.drawer__item--img').hide().append('<img src="'+figurl+'" alt="'+figalt+'" />').fadeIn();
			if (title)  $('.drawer__content--header').hide().append(title).fadeIn();
			if (death)  $('.drawer__content--header').after('<p><em>('+birth+' to '+death+')</em></p>').hide().fadeIn();
			if (desc)   $('.drawer__content--desc').hide().append(desc).fadeIn();
			if (figsrc) $('.drawer__content--desc').hide().append('<p class="text-muted">'+figsrc+' &mdash; '+figavl+'</p>').fadeIn();


			var arduino_req = function(pinid, state) {
				var requrl = ARDUINO_API_BASE_URL + pinid + state;
				console.log(requrl);

				$.ajax(requrl)
					.done(function(data) {
						console.log('done');
						tom.prevpinid = pinid;
					})
					.fail(function(data) {
						console.log('failed');
						tom.prevpinid = null;
					})
					.always(function(data) {
						console.log(data);
					});
			};

			var pinid = $this.data('ref').substring(1); /* remove '#' symbol */
			if (tom.prevpinid) arduino_req(tom.prevpinid, ARDUINO_API_LED_OFF);
			if (pinid)         arduino_req(pinid,         ARDUINO_API_LED_ON);
		});

		$('.was-distinct .was-orig').on('click', function(){
			if ( !tom.button.locked)
				tom.lockMagicButton();

			tom.highlightElement($(this));

			tom.emptyDrawer();
			var $this = $(this),
				orig  = $this.text(),
					alt   = $this.parent().find('.was-reg') ? $this.parent().find('.was-reg') : $this.parent().find('.was-seg');

					$('.drawer__item--content').addClass('distinct');
					$('.drawer__content--header').hide().append(orig).fadeIn();
					$('.drawer__content--desc').hide().append(alt.text()).fadeIn();
		});
	},
	emptyDrawer: function() {
		//$('#drawer .drawer').children().empty();
		$('.drawer__item--img').empty();
		$('.drawer__content--header').empty();
		$('.drawer__content--desc').empty();
	},
	highlightElement: function(elem) {
		$('.highlighted').removeClass('highlighted');
		elem.addClass('highlighted');
	},
	highlightElements: function() {
		$.each(tom.selectors, function(i, val){
			$(val).addClass('highlight');
		});
		tom.showDrawer();
	},
	unhighlightElements: function() {
		$.each(tom.selectors, function(i, val){
			$(val).removeClass('highlight');
		});
		tom.hideDrawer();
	},
	unhighlightElementsTimeout: function() {
		clearTimeout(tom.button.timeout);
		tom.button.timeout = setTimeout(tom.unhighlightElements, 4000);
	},

	hideMenuText: function() {
		$('.nav__text:not(.nav__text--magic)').css('opacity', '0');
	},
	showMenuText: function() {
		$('.nav__text:not(.nav__text--magic)').css('opacity', '1');
	},

	showLockText: function() {
		$('.nav__text--magic').html(tom.button.LOCK_TEXT);
	},
	showUnlockText: function() {
		$('.nav__text--magic').html(tom.button.UNLOCK_TEXT);
	},
	removeLockText: function() {
		$('.nav__text--magic').html(tom.button.MAGIC_TEXT);
	},

	showDrawer: function() {
		$('#drawer').addClass('show');
	},
	hideDrawer: function() {
		$('#drawer').removeClass('show');
		tom.emptyDrawer();
	},

	navScrollTo: function() {
		$('#navdrop h2, #navdrop h3').on('click', function() {
			var id      = $(this).attr('id'),
			    $target = $('#read').find('p[data-id="' + id + '"]');
			if ($target) {
				$('body').animate( {
						scrollTop: $target.offset().top - 74
					}
					, 500)
				;
				return false;
			}
		});
	}

}





















