require_relative '../../lib/togglv8'
require 'oj'

describe "Projects" do
  before :all do
    @toggl = Toggl::V8.new(Testing::TEST_API_TOKEN)
    @workspaces = @toggl.workspaces
    @workspace_id = @workspaces.first['id']
  end

  it 'receives {} if there are no workspace projects' do
    projects = @toggl.projects(@workspace_id)
    expect(projects).to be {}
  end

  context 'new project' do
    before :all do
      @project = @toggl.create_project({ name: 'project1', wid: @workspace_id })
    end

    after :all do
      TogglV8SpecHelper.delete_all_projects(@toggl)
    end

    it 'creates a project' do
      expect(@project).to_not be nil
      expect(@project['name']).to eq 'project1'
      expect(@project['billable']).to eq false
      expect(@project['is_private']).to eq true
      expect(@project['active']).to eq true
      expect(@project['template']).to eq false
      expect(@project['auto_estimates']).to eq false
      expect(@project['wid']).to eq @workspace_id
    end

    it 'gets project data' do
      project = @toggl.get_project(@project['id'])
      expect(project).to_not be nil
      expect(project['wid']).to eq @project['wid']
      expect(project['name']).to eq @project['name']
      expect(project['billable']).to eq @project['billable']
      expect(project['is_private']).to eq @project['is_private']
      expect(project['active']).to eq @project['active']
      expect(project['template']).to eq @project['template']
      expect(project['auto_estimates']).to eq @project['auto_estimates']
      expect(project['at']).to_not be nil
    end

    it 'updates project data' do
      new_values = {
        'name' => 'PROJECT-NEW',
        'is_private' => false,
        'active' => false,
        'auto_estimates' => true,
      }

      project = @toggl.update_project(@project['id'], new_values)
      expect(project).to include(new_values)
    end

    it 'updates Pro project data' do
      pending('Pro features') unless Testing::PRO_ACCOUNT

      new_values = {
        template: true,
        billable: true,
      }
      project = @toggl.update_project(@project['id'], new_values)
      expect(project).to include(new_values)
    end
  end

  context 'multiple projects' do
    after :all do
      TogglV8SpecHelper.delete_all_projects(@toggl)
    end

    it 'deletes multiple projects' do
      # start with no projects
      expect(@toggl.projects(@workspace_id)).to be {}

      p1 = @toggl.create_project({ name: 'p1', wid: @workspace_id })
      p2 = @toggl.create_project({ name: 'p2', wid: @workspace_id })
      p3 = @toggl.create_project({ name: 'p3', wid: @workspace_id })

      # see 3 new projects
      expect(@toggl.projects(@workspace_id).length).to eq 3

      p_ids = [p1, p2, p3].map { |p| p['id']}
      @toggl.delete_projects(p_ids)

      # end with no projects
      expect(@toggl.projects(@workspace_id)).to be {}
    end
  end
end