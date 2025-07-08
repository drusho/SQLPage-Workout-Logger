-- SQLPage Setup for Database-Driven Modal Component
-- Executed on: 2025-07-08

-- Step 1: Create the table to hold custom SQLPage files.
-- This table allows you to store templates and other files directly in the database,
-- which is useful for components that you want to be available globally.
CREATE TABLE IF NOT EXISTS sqlpage_files (
  path VARCHAR(255) NOT NULL PRIMARY KEY,
  contents BLOB NOT NULL,
  last_modified TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Step 2: Insert the Handlebars template for the modal component.
-- The 'path' is critical. SQLPage looks for templates in 'sqlpage/templates/'.
-- So, to create a component named 'modal', the path must be 'sqlpage/templates/modal.handlebars'.
-- Using REPLACE INTO will overwrite the file if it already exists, which is useful for updates.
REPLACE INTO sqlpage_files (path, contents, last_modified)
VALUES
(
    'sqlpage/templates/modal.handlebars',
    '<div class="modal{{~#if class}} {{class}}{{/if~}}" id="{{id}}" tabindex="-1" aria-hidden="false" aria-labelledby="{{title}}">
    <div role="document" class="modal-dialog {{#if small}} modal-sm{{/if}}{{#if large}} modal-lg{{/if}}{{#if scrollable}} modal-dialog-scrollable{{/if}}">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">{{title}}</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="{{default close "close"}}"></button>
            </div>
            <div class="modal-body">
                <div class="card bg-transparent border-0"
                    {{~#if (and embed (ne embed_mode "iframe"))}} data-pre-init="card" data-embed="{{embed}}"{{/if ~}}
                >
                    <div class="card-body p-0">
                        <div class="card-content remove-bottom-margin"></div>
                        {{~#if embed ~}}
                            {{~#if (eq embed_mode "iframe")}}
                                <iframe src="{{embed}}"
                                    width="100%"
                                    {{~#if height}} height="{{height}}"{{/if~}}
                                    {{~#if allow}} allow="{{allow}}"{{/if~}}
                                    {{~#if sandbox}} sandbox="{{sandbox}}"{{/if~}}
                                    {{~#if style}} style="{{style}}"{{/if~}}
                                >
                                </iframe>
                            {{~else~}}
                                <div class="d-flex justify-content-center h-100 align-items-center card-loading-placeholder">
                                    <div class="spinner-border" role="status" style="width: 3rem; height: 3rem;">
                                        <span class="visually-hidden">Loading...</span>
                                    </div>
                                </div>
                            {{~/if~}}
                        {{~/if~}}
                        {{~#each_row~}}
                            <p>
                                {{~#if contents_md~}}
                                    {{{markdown contents_md}}}
                                {{else}}
                                    {{~contents~}}
                                {{~/if~}}
                            </p>
                        {{~/each_row~}}
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                {{#if close}}<button type="button" class="btn me-primary" data-bs-dismiss="modal">{{close}}</button>{{/if}}
            </div>
        </div>
    </div>
</div>',
    CURRENT_TIMESTAMP
);
