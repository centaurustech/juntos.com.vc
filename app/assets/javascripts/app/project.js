App.addChild('Project', _.extend({
  el: '.content[data-action="show"][data-controller-name="projects"]',

  events: {
    'click #toggle_warning a' : 'toggleWarning',
    'click a#embed_link' : 'toggleEmbed'
  },

  activate: function(){
    this.$warning = this.$('#project_warning_text');
    this.$embed= this.$('#project_embed');
    this.route('about');
    this.route('basics');
    this.route('dashboard_project');
    this.route('dashboard_rewards');
    this.route('dashboard_subgoals');
    this.route('posts');
    this.route('contributions');
    this.route('comments');
    this.route('edit');
    this.route('reports');
    this.route('project_metrics');
    this.route('project_reports');
  },

  toggleWarning: function(){
    this.$warning.slideToggle('slow');
    return false;
  },

  toggleEmbed: function(){
    this.loadEmbed();
    this.$embed.slideToggle('slow');
    return false;
  },

  followRoute: function(name){
    var $tab = this.$('nav a[href="' + window.location.hash + '"]');
    if($tab.length > 0){
      this.onTabClick({ currentTarget: $tab });

      if(($tab.prop('id') == 'project_metrics_link') || ($tab.prop('id') == 'project_reports_link') || ($tab.prop('id') == 'basics_link') || ($tab.prop('id') == 'dashboard_project_link') || ($tab.prop('id') == 'dashboard_rewards_link') || ($tab.prop('id') == 'dashboard_subgoals_link')) {
        $('#project-sidebar').hide();
      } else {
        $('#project-sidebar').show();
      }
    }
  },

  loadEmbed: function() {
    var that = this;

    if(this.$embed.find('.loader').length > 0) {
      $.get(this.$embed.data('path')).success(function(data){
        that.$embed.html(data);
      });
    }
  }
}, Skull.Tabs));
